---
name: broll-organizer
description: Sort, rename, tag and catalog the user's B-roll library in "~/Movies/B-roll kit". Use when the user says "organize my b-roll", "sort my broll", "clean up the B-roll kit", "I added new b-roll", or before a video edit when `_inbox/` has files. Also answers "what b-roll do I have of X".
---

# B-roll Organizer

Library: `~/Movies/B-roll kit/` (local disk, not iCloud, not git). Catalog: `index.md` in that folder — the `video-editor` skill reads it to pick shots.

```
B-roll kit/
├── _inbox/        # user drops new files here (anything anywhere outside the folders below also counts as new)
├── clips/<topic>/ # video b-roll, one subfolder per topic (training, competition, gym, drills, travel, ...)
├── photos/<topic>/
├── logo/          # logo files — never renamed
├── graphics/      # overlays, stickers, end cards
├── music/         # audio beds / sfx
├── index.md       # catalog (agent-maintained)
└── log.md         # every move, newest first — the undo record
```

## Run

1. **Find new files:** everything in `_inbox/`, plus any media not listed in `index.md`. Skip `logo/`.
2. **Inspect each** (no network, read-only):
   ```bash
   ffprobe -v error -show_entries format=duration:stream=width,height,codec_type -show_entries format_tags=creation_time -of json "$f"
   FF=/opt/homebrew/opt/ffmpeg-full/bin/ffmpeg
   d=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f")
   $FF -v error -y -i "$f" -vf "fps=4/$d,scale=320:-1,tile=4x1" -frames:v 1 ~/VideoWork/thumb.jpg   # 4-frame strip, then Read it
   ```
   Look at the strip; describe what is in the shot in a few words.
3. **Propose, don't act yet.** Show one table: current path → new path, topic, tags, orientation (9:16 / 16:9), duration, quality notes (dark, shaky, blurry). Flag exact duplicates (`shasum -a 256`). Wait for "ok".
4. **Apply:** `mv -n` (never overwrite). Name: `YYYY-MM-DD_<topic>_<short-desc>_<v|h>.<ext>` (date from `creation_time`, else file mtime; lowercase, hyphens). Duplicates go to `_duplicates/` — never delete; tell the user they can remove them.
5. **Update `index.md`** — one table per top folder, columns: file, duration, orientation, tags, description. Keep rows sorted by path.
6. **Append to `log.md`:** date, then `old → new` per file.

## Rules

- Never delete, never re-encode, never edit the media itself. Only move/rename.
- Never touch `logo/` names (brand files are referenced by name).
- Bad shot (too dark, shaky, blurry)? Tag `needs-review`, say so honestly; don't move it to a trash folder.
- New topic folder only when ≥2 files share it; otherwise use the closest existing one.
- Unsure what a shot shows? Ask the user rather than guessing a name.
