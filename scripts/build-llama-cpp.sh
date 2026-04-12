#!/bin/bash
# Build llama.cpp — Vulkan only
# "You talkin' to me?" — Travis Bickle
# ROCm/HIP is for vLLM, FLM, PyTorch — not llama.cpp
set -euo pipefail

SRC="${1:-/srv/ai/llama-cpp}"

if [ ! -d "$SRC/.git" ]; then
    git clone https://github.com/ggml-org/llama.cpp "$SRC"
fi

cd "$SRC"
git pull

# Vulkan-only build — no HIP, no ROCm
cmake -B build -S . \
    -DGGML_VULKAN=ON \
    -DGGML_HIP=OFF \
    -DGGML_CUDA=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLAMA_CURL=ON \
    -G Ninja

cmake --build build --config Release -j$(nproc)

echo "llama.cpp: Vulkan build complete"
echo "Binary: $SRC/build/bin/llama-server"
