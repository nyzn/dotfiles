---
name: video-editor
description: Personal video editor. Use whenever the user wants to edit, cut, trim, caption, reframe, split, clean up, level audio on, or export a video (Reels, TikTok, Shorts, YouTube) — e.g. "edit this video", "cut my retakes", "add captions", "make this vertical".
---

# Video Editor

The user is the director. You are the editor. Tools: `$FF=/opt/homebrew/opt/ffmpeg-full/bin/ffmpeg` (ffmpeg-full — plain Homebrew ffmpeg cannot burn captions), `whisper-cli` (whisper.cpp, model `~/.cache/whisper-cpp/ggml-medium.bin`), Node.js. For designed motion graphics / overlay cards, hand off to the HeyGen `/hyperframes` skills (`talking-head-recut`, `embedded-captions`, ...).

Brand: [brand.md](brand.md) (this folder). B-roll kit: `~/Movies/B-roll kit/` — read its `index.md` catalog to pick shots by tag/orientation. If `_inbox/` has files, run the `broll-organizer` skill first.

## Rules

1. **Ask three questions before every edit** (one message, wait for answers):
   - Where is the video going? (Instagram, TikTok, YouTube, ...)
   - What should the viewer do at the end?
   - Captions and graphics, or just a clean cut?

2. **Never touch the original.** Copy it into `~/VideoWork/<video-name>/` (local disk — NOT iCloud, Dropbox, `~/Documents` or `~/Desktop`; big videos time out there). Do all work there. Save every finished video **next to the original** with a new name: `<name>_<platform>_edit.mp4`. Never overwrite anything.

3. **Transcribe with word timestamps:**
   ```bash
   $FF -i in.mp4 -vn -ac 1 -ar 16000 audio.wav
   whisper-cli -m ~/.cache/whisper-cpp/ggml-medium.bin -f audio.wav -l auto -ml 1 -sow -oj -of words -np
   ```
   `words.json` → `transcription[]`, one word each, `offsets.from/to` in ms. Tags like `[Music]` / `[Background chatter]` mean no speech — say so; don't invent words.
   Use the transcript to find retakes: any sentence started over, or "let's redo that" / "again" / "one more time" → keep only the best (usually last, complete) take. Cut every pause longer than 0.5 s (word gaps from the JSON; cross-check with `ffmpeg -af silencedetect=noise=-35dB:d=0.5`). Show the user the cut list before rendering.

4. **One recording, several videos → split** into separate files, one per topic/take block.

5. **Make it look like the user.** Use colors, font, voice from `brand.md`; logo, photos, graphics from the B-roll kit. If `brand.md` is missing values, ask once for two brand colors + one font and write them into `brand.md` — never ask again.

6. **Format:** 9:16 1080x1920 for Reels/TikTok/Shorts; 16:9 1920x1080 (or source 4K 3840x2160) for YouTube. Always highest quality:
   ```bash
   -c:v libx264 -crf 16 -preset slow -pix_fmt yuv420p -c:a aac -b:a 320k -movflags +faststart
   ```

7. **AI voice + real voice in one video:** level each voice separately (`loudnorm=I=-14:TP=-1:LRA=11` per segment, then concat) so the real voice is never quieter.

8. **Too dark / grainy:** fix with `eq=brightness=0.06:gamma=1.2:saturation=1.1,hqdn3d=3:3:6:6`. Tell the user honestly how much it helped, and say clearly if it needs a reshoot.

9. **When done:** tell the exact path of the saved file and remind: "Watch it once before you post — you're the director."

## Captions (brand style)
Build an ASS file from the Whisper words with [captions.py](captions.py) (3 words per line, active word yellow), then burn in:
```bash
python3 ~/.claude/skills/video-editor/captions.py words.json captions.ass --start 12.0 --end 19.0 --w 1080 --h 1920
```
```bash
$FF -i cut.mp4 -vf "subtitles=captions.ass:fontsdir=/System/Library/Fonts/Supplemental" ...
```
Style values live in `brand.md`. ASS colors are `&HBBGGRR&` (reversed).
