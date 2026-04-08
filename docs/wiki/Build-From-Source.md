# Build From Source

> "If you want it done right, build it yourself."

## The Philosophy

Pre-built binaries are someone else's choices baked in. When you build from source, you control:

- Which GPU targets are compiled (gfx1151, not generic)
- Which optimizations are enabled
- Which features are included
- Which version you're running

The hardware is here. The horsepower is here. Use it.

## When to Build from Source

- **GPU-accelerated software** — needs your specific GPU target
- **Performance-critical tools** — compiler flags matter
- **Bleeding edge** — you need a feature that isn't in a release yet
- **Custom patches** — you need to modify the code

## When NOT to Build from Source

- **Standard tools** — git, curl, htop → use `pacman`
- **Stable releases** — if the Arch package works, use it
- **Python packages** — use pip in a venv

## Build Environment

The install script sets up everything you need:

```bash
sudo pacman -S base-devel git cmake make
```

For ROCm builds:

```bash
export PATH=$PATH:/opt/rocm/bin
export HIP_PATH=/opt/rocm
export ROCM_PATH=/opt/rocm
```

## Example: llama.cpp

```bash
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp

cmake -B build \
    -DGGML_HIP=ON \
    -DGGML_VULKAN=ON \
    -DAMDGPU_TARGETS=gfx1151 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_HIP_COMPILER=/opt/rocm/bin/amdclang++

cmake --build build --config Release -j$(nproc)

sudo cp build/bin/llama-server /usr/local/bin/
```

## Zen 5 Optimization Flags

For maximum performance on Zen 5 (Ryzen 9000 / Strix Halo):

```bash
-march=znver5 -mtune=znver5 -O3
```

These are set automatically by `-march=native` on Zen 5 hardware.

## Updating a Source Build

```bash
cd ~/llama.cpp
git pull
cmake --build build --config Release -j$(nproc)
sudo cp build/bin/llama-server /usr/local/bin/
sudo systemctl restart llama-server
```

## Package Priority (Reminder)

1. Official Arch repos (`pacman`)
2. AUR (`yay`)
3. Source builds
4. pip in venv
5. Flatpak (last resort)
