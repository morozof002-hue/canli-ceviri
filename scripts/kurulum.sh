#!/usr/bin/env bash
# HUAN migration build: keep both native engines available until legacy sources are removed.
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
fi
LLAMA_COMMIT=25747b08e7a0f9a59a2089ce6b98d2229b76042a
if [ ! -d third_party/llama.cpp ]; then
  git clone https://github.com/ggml-org/llama.cpp.git third_party/llama.cpp
fi
git -C third_party/llama.cpp fetch --depth 1 origin $LLAMA_COMMIT 2>/dev/null || true
git -C third_party/llama.cpp checkout -q $LLAMA_COMMIT
echo "Native dependencies ready."
