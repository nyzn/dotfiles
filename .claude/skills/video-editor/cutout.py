#!/usr/bin/env python3
"""Cutout transition: the people of clip B appear as outlined cutouts over the end of clip A,
then B's background flashes in.

usage: cutout.py A.mp4 B.mp4 N OUT      ->  OUT_a.mp4  OUT_x.mp4  OUT_b.mp4   (concat in that order)

  A, B  rendered clips of the same size and frame rate, no rotation metadata; audio is optional
  N     transition length in frames (15 = 0.5 s at 29.97 fps)

The three parts hold exactly na-N, N and nb-N frames, share stereo 48 kHz audio (silence where a
clip has none) and bt709 tags, so `-f concat -c copy` joins them cleanly with other segments
encoded the same way. Uses $FF / $FP for ffmpeg / ffprobe when set.
"""
import os, subprocess, sys

FF = os.environ.get("FF") or "ffmpeg"
FP = os.environ.get("FP") or "ffprobe"


def die(msg):
    sys.exit(f"cutout.py: {msg}")


def run(cmd, **kw):
    r = subprocess.run(cmd, capture_output=True, **kw)
    if r.returncode:
        err = r.stderr if isinstance(r.stderr, str) else r.stderr.decode(errors="replace")
        die(f"{os.path.basename(cmd[0])} failed:\n{err.strip()[-600:]}")
    return r.stdout


def probe(path):
    if not os.path.isfile(path):
        die(f"no such file: {path}")
    out = run([FP, "-v", "error", "-count_frames", "-select_streams", "v:0", "-show_entries",
               "stream=width,height,r_frame_rate,nb_read_frames", "-of", "csv=p=0", path], text=True)
    w, h, rate, n = out.strip().split(",")[:4]
    audio = run([FP, "-v", "error", "-select_streams", "a:0", "-show_entries", "stream=index",
                 "-of", "csv=p=0", path], text=True).strip() != ""
    return int(w), int(h), rate, int(n), audio


def read(path, start, n, w, h):
    raw = run([FF, "-v", "error", "-i", path, "-vf",
               f"trim=start_frame={start}:end_frame={start + n},setpts=PTS-STARTPTS,"
               "scale=in_color_matrix=bt709:in_range=tv", "-pix_fmt", "bgr24", "-f", "rawvideo", "-"])
    if len(raw) != n * w * h * 3:
        die(f"expected {n} frames from {path}, got {len(raw) / (w * h * 3):g}")
    import numpy as np
    return np.frombuffer(raw, np.uint8).reshape(n, h, w, 3)


def audio_args(path, has_audio, start, dur, index):
    """Input + filter that yield exactly `dur` seconds of stereo 48 kHz audio starting at `start`."""
    if has_audio:
        return (["-i", path],
                f"[{index}:a:0]aresample=48000,atrim=start={start:.6f},asetpts=PTS-STARTPTS,"
                f"apad=whole_dur={dur:.6f},atrim=end={dur:.6f}[a]")
    return (["-f", "lavfi", "-i", "anullsrc=r=48000:cl=stereo"], f"[{index}:a]atrim=end={dur:.6f}[a]")


ENC = ["-c:v", "libx264", "-preset", "medium", "-crf", "17", "-profile:v", "high", "-pix_fmt", "yuv420p",
       "-colorspace", "bt709", "-color_primaries", "bt709", "-color_trc", "bt709",
       "-c:a", "aac", "-b:a", "192k", "-ac", "2", "-ar", "48000"]


def main():
    if len(sys.argv) != 5 or not sys.argv[3].isdigit():
        die("usage: cutout.py A.mp4 B.mp4 N OUT")
    A, B, N, OUT = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4]
    try:
        import cv2
        import numpy as np
        from rembg import new_session, remove
    except ImportError as e:
        die(f"{e}. Install with: WITH_CUTOUT=1 setup.sh  (or pip install 'rembg[cpu]' opencv-python-headless numpy)")

    w, h, rate, na, a_audio = probe(A)
    wb, hb, rate_b, nb, b_audio = probe(B)
    if (w, h, rate) != (wb, hb, rate_b):
        die(f"clips differ: A is {w}x{h} @ {rate}, B is {wb}x{hb} @ {rate_b}; render both the same first")
    if not 0 < N < min(na, nb):
        die(f"N must be between 1 and {min(na, nb) - 1} (A has {na} frames, B has {nb})")
    num, den = (int(x) for x in rate.split("/"))
    fps = num / den

    session = new_session("u2net_human_seg")     # before the slow part, so a missing model fails early
    fa, fb = read(A, na - N, N, w, h), read(B, 0, N, w, h)

    # cut_x: N composite frames, with the matching tail of A's audio
    ain, afilt = audio_args(A, a_audio, (na - N) / fps, N / fps, 1)
    enc = subprocess.Popen(
        [FF, "-v", "error", "-y", "-f", "rawvideo", "-pix_fmt", "bgr24", "-s", f"{w}x{h}", "-r", rate, "-i", "-"]
        + ain + ["-filter_complex", "[0:v]scale=out_color_matrix=bt709:out_range=tv[v];" + afilt,
                 "-map", "[v]", "-map", "[a]", "-frames:v", str(N)] + ENC + [OUT + "_x.mp4"],
        stdin=subprocess.PIPE, stderr=subprocess.PIPE)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (15, 15))
    try:
        for i in range(N):
            m = np.array(remove(cv2.cvtColor(fb[i], cv2.COLOR_BGR2RGB), session=session, only_mask=True))
            m = cv2.GaussianBlur(m, (0, 0), 2)
            _, hard = cv2.threshold(m, 110, 255, cv2.THRESH_BINARY)
            ring = cv2.GaussianBlur(cv2.dilate(hard, kernel), (0, 0), 1.5).astype(np.float32) / 255
            a = m.astype(np.float32) / 255
            fg = fb[i].astype(np.float32)
            s = 1 + 0.18 * max(0, 1 - i / 5) ** 2                      # pop-in: cutout scales 1.18 -> 1.0 over 5 frames
            if s > 1.001:
                M = cv2.getRotationMatrix2D((w / 2, h * 0.55), 0, s)
                fg, a, ring = (cv2.warpAffine(x, M, (w, h)) for x in (fg, a, ring))
            op = min(1, (i + 1) / 3)
            out = fa[i].astype(np.float32) * (1 - 0.35 * min(1, i / 4))  # dim clip A under the cutout
            out = out * (1 - ring[..., None] * op) + 255 * ring[..., None] * op   # white outline
            out = out * (1 - a[..., None] * op) + fg * a[..., None] * op
            enc.stdin.write(np.clip(out, 0, 255).astype(np.uint8).tobytes())
        enc.stdin.close()
    except BrokenPipeError:
        pass
    err = enc.stderr.read().decode(errors="replace")
    if enc.wait():
        die(f"encoding {OUT}_x.mp4 failed:\n{err.strip()[-600:]}")

    # cut_a: A without its last N frames; cut_b: B from frame N on, opening with a white flash
    ain, afilt = audio_args(A, a_audio, 0, (na - N) / fps, 1)
    run([FF, "-v", "error", "-y", "-i", A] + ain
        + ["-filter_complex", f"[0:v:0]trim=end_frame={na - N},setpts=PTS-STARTPTS[v];" + afilt,
           "-map", "[v]", "-map", "[a]", "-frames:v", str(na - N)] + ENC + [OUT + "_a.mp4"])
    ain, afilt = audio_args(B, b_audio, N / fps, (nb - N) / fps, 1)
    run([FF, "-v", "error", "-y", "-i", B] + ain
        + ["-filter_complex",
           f"[0:v:0]trim=start_frame={N},setpts=PTS-STARTPTS,fade=t=in:d=0.14:color=white[v];" + afilt,
           "-map", "[v]", "-map", "[a]", "-frames:v", str(nb - N)] + ENC + [OUT + "_b.mp4"])
    print(f"{OUT}_a.mp4 ({na - N} frames)  {OUT}_x.mp4 ({N})  {OUT}_b.mp4 ({nb - N})")


if __name__ == "__main__":
    main()
