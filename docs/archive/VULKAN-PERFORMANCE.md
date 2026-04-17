# Vulkan vs ROCm — Why Vulkan Only for llama.cpp

## Decision

As of v10.2.0, halo-ai-core builds llama.cpp with **Vulkan only** (h/t u/Look_0ver_There). ROCm/HIP and OpenCL backends were removed from the installer.

## Benchmark Results (Strix Halo — AMD Ryzen AI MAX+ 395)

Tested with PrismML Bonsai 1-bit models. Vulkan build compiled with Flash Attention + Zen 5 optimizations.

| Model | Vulkan gen tok/s | ROCm gen tok/s | Vulkan wins by |
|-------|-----------------|----------------|----------------|
| Bonsai 8B | **103.7** | 90.6 | +14% |
| Bonsai 4B | **148.3** | 122.2 | +21% |
| Bonsai 1.7B | **260.0** | 230.8 | +13% |

Vulkan wins generation speed by **13-21%** across all model sizes.

### Prompt Processing

ROCm is faster at prompt processing (pp512):

| Model | Vulkan pp tok/s | ROCm pp tok/s |
|-------|----------------|----------------|
| Bonsai 8B | 330 | **714** |

For interactive use (chatbots, agents, voice), generation speed matters more than prompt processing. The model spends most of its time generating tokens, not processing the prompt.

## Why Not Both?

- Building HIP + Vulkan + OpenCL adds ~10 minutes of compile time
- Three build directories waste disk space
- Service configs need to know which binary to use
- Vulkan is the clear winner for the primary use case (LLM inference)
- Simpler is better — one backend, one binary, one config

## ROCm Still Used For

ROCm is still installed for services that require it:
- **vLLM** — no Vulkan backend available
- **whisper.cpp** — HIP backend for speech-to-text

These services use ROCm independently of llama.cpp.

## Reproduce

```bash
# Build llama.cpp Vulkan only
cd /srv/ai/llama-cpp
cmake -B build -DGGML_VULKAN=ON -DCMAKE_BUILD_TYPE=Release -G Ninja .
cmake --build build -j$(nproc)

# Run benchmark
./build/bin/llama-bench -m /path/to/model.gguf -t $(nproc)
```

## References

- Benchmark data: PrismML-Eng/Bonsai-demo#19
- Zen 5 optimization flags: `/srv/ai/configs/rocm.env`

Designed and built by the architect.
