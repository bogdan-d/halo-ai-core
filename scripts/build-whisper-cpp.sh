#!/bin/bash
set -euo pipefail

SRC=/srv/ai/whisper-cpp
cd "$SRC"

if [ ! -d .git ]; then
    git clone https://github.com/ggerganov/whisper.cpp .
else
    git pull
fi

cmake -B build -S . \
    -DGGML_VULKAN=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -G Ninja
cmake --build build --config Release -j$(nproc)

echo 'whisper.cpp: build complete'
