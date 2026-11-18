#!/bin/zsh
# HUAN: only whisper.cpp is required for local speech recognition.
set -e
cd "$(dirname "$0")/.."
WHISPER_COMMIT=6e4ab854f67f743900934a703d5603419384c961
if [ ! -d third_party/whisper.cpp ]; then
  git clone https://github.com/ggml-org/whisper.cpp.git third_party/whisper.cpp
fi
git -C third_party/whisper.cpp fetch --depth 1 origin $WHISPER_COMMIT 2>/dev/null || true
git -C third_party/whisper.cpp checkout -q $WHISPER_COMMIT
PATCH="$PWD/scripts/whisper-kodlama-paylasimi.patch"
if git -C third_party/whisper.cpp apply --reverse --check "$PATCH" 2>/dev/null; then
  echo "whisper.cpp patch already applied"
else
  git -C third_party/whisper.cpp apply "$PATCH"
  echo "whisper.cpp patch applied"
fi
echo "whisper.cpp ready: $(git -C third_party/whisper.cpp log -1 --format='%h %cs')"
