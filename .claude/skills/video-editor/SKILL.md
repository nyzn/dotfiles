---
name: video-editor
description: Personal video editor. Use whenever the user wants to edit, cut, trim, caption, reframe, split, clean up, level audio on, add transitions or effects (flash, glitch, slow-mo, "Person Flash" = cutout / "Scene-Screen" transition) to, or export a video, or turn clips into a Reel/TikTok/Short/Story/YouTube video — e.g. "edit this video", "cut my retakes", "add captions", "make this vertical", "make a reel from these clips", "füge Person Flash hinzu".
---

# Video Editor

The user is the director. You are the editor. Works on macOS (Claude Code locally) and Linux (cloud sessions, claude.ai) — resolve tools first, never assume a path.

Companion files sit next to this one: [brand.md](brand.md), [captions.py](captions.py), [cutout.py](cutout.py), [setup.sh](setup.sh). If they are missing (e.g. this skill was synced to claude.ai as a single file), fetch them after step 0:
```bash
SK=https://raw.githubusercontent.com/nyzn/dotfiles/main/.claude/skills/video-editor
mkdir -p "$W/_skill" && for f in brand.md captions.py cutout.py; do curl -fsSL "$SK/$f" -o "$W/_skill/$f"; done
```

## 0. Resolve the environment (once per session)

```bash
FF=$(command -v /opt/homebrew/opt/ffmpeg-full/bin/ffmpeg || command -v ffmpeg)   # ffmpeg-full on Mac: plain Homebrew ffmpeg has no libass
FP=$(command -v /opt/homebrew/opt/ffmpeg-full/bin/ffprobe || command -v ffprobe)
$FF -hide_banner -filters | grep -qE ' subtitles ' || echo "no libass -> no burned captions; run setup.sh"
$FF -hide_banner -filters | grep -qE ' zscale '    || echo "no zscale -> no HDR tonemap; run setup.sh"
W=${VIDEO_WORK:-$HOME/VideoWork}; [ -w "$(dirname "$W")" ] || W=$(mktemp -d)        # cloud: use the session scratchpad instead
WHISPER=$(command -v whisper-cli); WMODEL=~/.cache/whisper-cpp/ggml-medium.bin
```
Font: `Futura` (Bold) if `fc-list | grep -qi futura` or on macOS (`/System/Library/Fonts/Supplemental`), otherwise `Inter` Bold, otherwise `DejaVu Sans` Bold. Use the same font for captions and text overlays.

Tools missing → run `setup.sh` (brew on macOS, apt on Linux). If a step still can't work (e.g. no Whisper model because huggingface.co is unreachable from a cloud sandbox), say so in one line and carry on without that step — never fake a transcript.

## 1. Ask three questions before every edit
One message, wait for answers (if nobody is there to answer, pick: Instagram Reels / no CTA / short text overlays, and say so at the top):
- Where is the video going? (Instagram, TikTok, YouTube, ...)
- What should the viewer do at the end?
- Captions and graphics, or just a clean cut?

## 2. Never touch the original
Work in `$W/<video-name>/` on local disk (NOT iCloud, Dropbox, `~/Documents`, `~/Desktop` — big videos time out there). Save the result **next to the original** as `<name>_<platform>_edit.mp4`; never overwrite. If the originals are read-only uploads (cloud session), deliver the file to the user instead and say where it is.

## 3. Inspect before cutting
For every clip:
```bash
$FP -v error -show_entries format=duration:stream=codec_type,width,height,r_frame_rate,color_transfer:stream_side_data=rotation -show_entries format_tags=com.apple.quicktime.creationdate -of compact "$f"
d=$($FP -v error -show_entries format=duration -of csv=p=0 "$f")
$FF -v error -y -i "$f" -vf "fps=8/$d,scale=320:-2,tile=8x1" -frames:v 1 "$W/sheet_$(basename "$f").jpg"   # then Read it
```
- **Order** clips by `com.apple.quicktime.creationdate` (camera time), not by file name or upload time.
- **Rotation:** ffmpeg auto-rotates; a 3840x2160 clip with rotation -90 is portrait.
- **HDR:** `color_transfer=arib-std-b67` (HLG, every recent iPhone) or `smpte2084` (PQ) must be tonemapped to SDR or it looks washed out on Instagram/TikTok. Scale first, tonemap second (much faster on 4K):
  ```bash
  TM="zscale=t=linear:npl=203,format=gbrpf32le,zscale=p=bt709,tonemap=mobius:desat=0:param=0.3,zscale=t=bt709:m=bt709:r=tv,format=yuv420p"
  ```
  Check one tonemapped still before rendering everything.

## 4. Talking content → transcribe and cut
Only if the clip has speech and Whisper is available:
```bash
$FF -i in.mp4 -vn -ac 1 -ar 16000 audio.wav
$WHISPER -m $WMODEL -f audio.wav -l auto -ml 1 -sow -oj -of words -np
```
`words.json` → `transcription[]`, one word each, `offsets.from/to` in ms. Tags like `[Music]` / `[Background chatter]` mean no speech — say so; don't invent words.
Find retakes: a sentence started over, or "let's redo that" / "again" / "one more time" → keep the best (usually last, complete) take. Cut every pause > 0.5 s (word gaps; cross-check with `-af silencedetect=noise=-35dB:d=0.5`). Show the cut list before rendering.

One recording with several topics → split into separate files.

## 5. No speech (b-roll, commute, vlog clips) → montage
- Tell the story in camera order; pick the best 3–10 s of each clip from the contact sheet.
- Speed-ramp long, uneventful stretches (`setpts=PTS/3` … `/4`), keep moments (a view, a sign, an arrival) at 1–1.5x. Target 30–45 s for Reels/TikTok.
- Drop the original audio when it's sped up (it sounds broken); add music only if the user supplies a track or the B-roll kit has one — never pull music from the web.
- Text overlays = short labels for the story beats (time, place, "arrived"), 2–2.5 s each, fade in/out, in the brand font, upper third. Put the label in a file and use `textfile=` — inline `text='06:40'` breaks at the `:` (option separator) and renders only "06":
  ```bash
  printf '06:40 – Abfahrt' > "$W/label1.txt"
  drawtext=fontfile=$FONTFILE:textfile=$W/label1.txt:fontsize=68:fontcolor=white:shadowcolor=black@0.6:shadowy=4:x=(w-tw)/2:y=h*0.16:alpha='if(lt(t,0.2),t/0.2,if(lt(t,2.2),1,max(0,(2.6-t)/0.4)))'
  ```
- Render each segment separately (in parallel), then concat with `-f concat -c copy`, then one final pass for fades + an audio track (silent `anullsrc` if there is no music — some apps and editors choke on video-only files).

## 5b. Transitions and effects (only when the user asks for effects)
Apply effects after scaling to the output size, on the first/last 0.1–0.3 s of a segment. Vary them — one kind per cut, not the same flash everywhere. `D` = segment duration.
- **Flash:** in `fade=t=in:d=0.16:color=white`, out `fade=t=out:st=<D-0.1>:d=0.1:color=white`.
- **RGB glitch:** `rgbashift=rh=28:bh=-28:gv=10:enable='lt(t,0.2)'` on the incoming clip, mirrored (`rh=-28:bh=28`, `enable='gt(t,<D-0.15>)'`) on the outgoing one.
- **Whip blur:** `gblur=sigma=70:sigmaV=0.3:steps=2:enable='lt(t,0.07)',gblur=sigma=30:sigmaV=0.3:steps=2:enable='between(t,0.07,0.15)'`; mirror at the end of the outgoing clip.
- **Zoom punch:** `scale=w='2*trunc(540*(1+0.35*max(0,1-t/0.3)))':h='2*trunc(960*(1+0.35*max(0,1-t/0.3)))':eval=frame,crop=1080:1920`.
- **Slow-mo on the key moment:** split the segment into parts and render the key 1–1.5 s at half speed: `setpts=(PTS-STARTPTS)/0.5,minterpolate=fps=30000/1001:mi_mode=blend`, audio `atempo=0.5`. Optional 1.12x punch-in on that part.
- **Follow the subject** when reframing landscape → 9:16 (sports, sparring): build a contact sheet at 2 fps with `drawgrid=w=iw/10:h=ih`, note the subject's centre x (0–1) every 0.5 s, smooth it, and feed it to `crop` as a piecewise-linear x expression. Ask (or check memory) what the user is wearing that day so you track the right person. Read a sheet of the result and confirm the subject never leaves the frame. If the user wants to see more, crop wider (e.g. 1620x2160 → 1080x1440) over a blurred copy of the same clip.

### Cutout transition (the user calls it "Person Flash" or "Scene-Screen-Effekt")
**Trigger words:** "Person Flash", "Personen-Flash", "flash me in", "Flash auf die Person", "Scene-Screen-Effekt" all mean this transition — do not ask what is meant and do not substitute the plain white **Flash** from the list above (that one is only for a bare "flash" / "Blitz"). If the user names no cut, pick the 1–2 cuts where they enter the frame most clearly and say which ones you chose.

The people of the **next** clip appear first as cutouts (white outline, quick pop-in) over the last ~0.5 s of the **current** clip; then the next clip's background flashes in. Use it on 1–2 cuts per video.

Needs `rembg`, `opencv-python-headless` and `numpy`: run `WITH_CUTOUT=1 setup.sh` once (or `pip install "rembg[cpu]" opencv-python-headless numpy`, with `--break-system-packages` on system Pythons). The `u2net_human_seg` model downloads from GitHub on first use; if that fails (sandbox), say so in one line and use a flash at that cut instead. Render both clips first at the same output size and frame rate, **without** any other effect at that cut (video-only segments are fine), then run the companion [cutout.py](cutout.py) — it is in `$W/_skill/` if the companion files were fetched:
```bash
FF=$FF FP=$FP python3 cutout.py segA.mp4 segB.mp4 15 "$W/cut"     # 15 frames = 0.5 s  ->  cut_a.mp4, cut_x.mp4, cut_b.mp4
```
The parts come out as x264 crf 17, stereo 48 kHz AAC (silence if a clip has no audio) and bt709; `-f concat -c copy` only works if the other segments are encoded the same way, otherwise re-encode in the final pass. The first 0.5 s of clip B's own audio is replaced by the tail of clip A's.
In the concat list replace `segA.mp4`, `segB.mp4` with `cut_a.mp4`, `cut_x.mp4`, `cut_b.mp4` — write that list by hand, in this order (`ls` sorts `cut_b` before `cut_x`). Read a sheet of `cut_x.mp4` before delivering: if the mask grabs bystanders or misses the subject, say so and use a flash at that cut instead. It reads best when the two clips' subjects sit in different parts of the frame.

## 6. Make it look like the user
Colors, font and voice from `brand.md`; logo, photos, graphics, music from the B-roll kit `~/Movies/B-roll kit/` (read its `index.md`; if `_inbox/` has files, run `broll-organizer` first). If `brand.md` lacks values, ask once for two brand colors + one font and write them in — never ask again.

## 7. Format and quality
9:16 1080x1920 for Reels/TikTok/Shorts (`scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920`); 16:9 1920x1080 (or 3840x2160) for YouTube. Always 30 fps for 9:16 unless the user wants slow-mo. Final encode:
```bash
-c:v libx264 -crf 16 -preset slow -pix_fmt yuv420p -c:a aac -b:a 320k -movflags +faststart
```

## 8. Audio
AI voice + real voice in one video: level each separately (`loudnorm=I=-14:TP=-1:LRA=11` per segment, then concat) so the real voice is never quieter.

## 9. Too dark / grainy
`eq=brightness=0.06:gamma=1.2:saturation=1.1,hqdn3d=3:3:6:6`. Tell the user honestly how much it helped; say clearly if it needs a reshoot.

## 10. Captions (brand style)
```bash
python3 captions.py words.json captions.ass --start 12.0 --end 19.0 --w 1080 --h 1920 --font "$FONT"
$FF -i cut.mp4 -vf "subtitles=captions.ass${FONTSDIR:+:fontsdir=$FONTSDIR}" ...   # FONTSDIR=/System/Library/Fonts/Supplemental on macOS, unset on Linux
```
Style values live in `brand.md`. ASS colors are `&HBBGGRR&` (reversed).

## 11. Before delivering
Build a contact sheet of the final file and Read it (check order, crop, text, no black frames). Then give the exact path and remind: "Watch it once before you post — you're the director."

For designed motion graphics / overlay cards, hand off to the HeyGen Hyperframes skills (`embedded-captions`, `talking-head-recut`, `motion-graphics`, ...) if installed (`setup.sh` installs them).
