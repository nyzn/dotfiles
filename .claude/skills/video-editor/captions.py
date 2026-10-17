#!/usr/bin/env python3
"""Whisper word-timestamp JSON -> brand-styled ASS captions (active word highlighted).

Input: whisper.cpp JSON from `whisper-cli ... -ml 1 -sow -oj` (one word per segment),
or openai-whisper JSON with --word_timestamps True.

usage: captions.py whisper.json out.ass [--start S] [--end E] [--w 1080] [--h 1920] [--words 3]
Times in the ASS are shifted so --start becomes 0 (matches a clip cut at --start).
Colors/font mirror brand.md — update both together.
"""
import argparse, json

FONT, TEXT, ACTIVE, OUTLINE = "Futura", "&H00FFFFFF", "&H0015CCFA", "&H00000000"  # white, yellow, black


def ts(t):
    cs = round(max(t, 0) * 100)
    return f"{cs // 360000}:{cs // 6000 % 60:02}:{cs // 100 % 60:02}.{cs % 100:02}"


def main():
    a = argparse.ArgumentParser()
    a.add_argument("json"); a.add_argument("out")
    a.add_argument("--start", type=float, default=0); a.add_argument("--end", type=float, default=1e9)
    a.add_argument("--w", type=int, default=1080); a.add_argument("--h", type=int, default=1920)
    a.add_argument("--words", type=int, default=3)
    o = a.parse_args()

    d = json.load(open(o.json))
    if "transcription" in d:  # whisper.cpp; drop non-speech tags like [Music]
        raw = [{"word": t["text"], "start": t["offsets"]["from"] / 1000, "end": t["offsets"]["to"] / 1000}
               for t in d["transcription"] if t["text"].strip() and not t["text"].strip()[:1] in "[(" and not t["text"].strip()[-1:] in "])"]
    else:
        raw = [w for s in d["segments"] for w in s.get("words", [])]
    words = [w for w in raw if w["start"] >= o.start and w["end"] <= o.end]
    size, margin = round(o.h * 0.042), round(o.h * 0.25)
    out = [
        "[Script Info]", "ScriptType: v4.00+", f"PlayResX: {o.w}", f"PlayResY: {o.h}", "",
        "[V4+ Styles]",
        "Format: Name, Fontname, Fontsize, PrimaryColour, OutlineColour, BackColour, Bold, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV",
        f"Style: Cap,{FONT},{size},{TEXT},{OUTLINE},&H80000000,1,1,6,2,2,60,60,{margin}", "",
        "[Events]", "Format: Layer, Start, End, Style, Text",
    ]
    for i in range(0, len(words), o.words):
        group = words[i:i + o.words]
        for j, w in enumerate(group):  # one event per word: whole line shown, current word yellow
            end = group[j + 1]["start"] if j + 1 < len(group) else w["end"]
            line = " ".join((f"{{\\c{ACTIVE}}}{g['word'].strip().upper()}{{\\c{TEXT}}}" if k == j
                             else g["word"].strip().upper()) for k, g in enumerate(group))
            out.append(f"Dialogue: 0,{ts(w['start'] - o.start)},{ts(end - o.start)},Cap,{line}")
    open(o.out, "w").write("\n".join(out) + "\n")


if __name__ == "__main__":
    main()
