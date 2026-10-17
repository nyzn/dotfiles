#!/usr/bin/env bash
# Install what the video-editor skill needs. macOS (Homebrew) or Debian/Ubuntu (apt). Safe to re-run.
#   ~/.claude/skills/video-editor/setup.sh
set -euo pipefail

if [ "$(uname)" = Darwin ]; then
  # ffmpeg-full: plain Homebrew ffmpeg lacks libass (no burned captions). whisper-cpp: openai-whisper's model host is gone.
  for f in ffmpeg-full whisper-cpp node; do brew list "$f" >/dev/null 2>&1 || brew install "$f"; done
  mkdir -p ~/Movies/"B-roll kit"/{_inbox,clips,photos,logo,graphics,music}
else
  # Debian/Ubuntu ffmpeg ships libass + zimg. whisper.cpp has no apt package -> build it only if asked.
  SUDO=$([ "$(id -u)" = 0 ] && echo "" || echo sudo)
  command -v ffmpeg >/dev/null || { $SUDO apt-get update -qq && $SUDO apt-get install -y -qq ffmpeg fonts-dejavu-core; }
  if [ "${WITH_WHISPER:-0}" = 1 ] && ! command -v whisper-cli >/dev/null; then
    $SUDO apt-get install -y -qq cmake build-essential git
    git clone --depth 1 https://github.com/ggerganov/whisper.cpp /tmp/whisper.cpp
    cmake -S /tmp/whisper.cpp -B /tmp/whisper.cpp/build -DCMAKE_BUILD_TYPE=Release >/dev/null
    cmake --build /tmp/whisper.cpp/build -j --target whisper-cli >/dev/null
    $SUDO install /tmp/whisper.cpp/build/bin/whisper-cli /usr/local/bin/
  fi
fi

# Whisper model (skipped quietly if huggingface.co is unreachable, e.g. in a sandbox).
m=~/.cache/whisper-cpp/ggml-medium.bin
if command -v whisper-cli >/dev/null && [ ! -f "$m" ]; then
  mkdir -p "${m%/*}"
  curl -fL -C - --retry 10 -o "$m" https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-medium.bin \
    || { rm -f "$m"; echo "Whisper model download failed — captions from speech unavailable on this machine."; }
fi

# HeyGen Hyperframes motion-graphics skills -> ~/.claude/skills (user-level, untracked: see ~/.claude/.gitignore).
if command -v npx >/dev/null && [ ! -e ~/.claude/skills/hyperframes ]; then
  npx -y skills add heygen-com/hyperframes -a claude-code -g -s '*' -y || echo "Hyperframes install failed — video-editor works without it."
fi

mkdir -p "${VIDEO_WORK:-$HOME/VideoWork}"
echo "Done. ffmpeg: $(command -v /opt/homebrew/opt/ffmpeg-full/bin/ffmpeg || command -v ffmpeg)  work dir: ${VIDEO_WORK:-$HOME/VideoWork}"
