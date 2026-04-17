# Bonsai 1-Bit on Strix Halo — 359 tok/s Generation, 5,027 tok/s Prompt Processing

*April 13, 2026 · stamped by the architect · h/t u/wallysimmonds*

---

## The Numbers

| Model | Size on Disk | pp512 tok/s | tg128 tok/s |
|-------|-------------|-------------|-------------|
| **Bonsai 1.7B** | 231 MiB | **5,027** | **359.5** |
| **Bonsai 4B** | 540 MiB | **1,998** | **190.1** |
| **Bonsai 8B** | 1.07 GiB | **1,164** | **122.0** |

Q1_0 quantization (1-bit ternary weights). PrismML Bonsai models. Stock llama.cpp Vulkan backend. GPU forced to high performance mode.

## What This Means

- The **1.7B fits in 231 MB** and generates at 359 tok/s. Real-time conversational speed on a model that barely touches memory.
- The **8B fits in 1 GB** and still does 122 tok/s. For context, Qwen3 8B at Q4 does 90 tok/s and takes 5x the memory.
- Prompt processing on the 1.7B is over **5,000 tok/s**. Feed it a full document and it processes it in milliseconds.
- 128GB unified memory means you can stack multiple 1-bit models alongside full-precision models. The 1.7B uses 231 MB. That's nothing.

## Hardware

```
CPU:      Ryzen AI MAX+ 395 (32c Zen 5)
GPU:      Radeon 8060S (RDNA 3.5, gfx1151)
Memory:   128GB unified DDR5
Kernel:   6.19.11-arch1-1
Backend:  llama.cpp Vulkan (stock)
Driver:   RADV Mesa 26.0.4
GPU Mode: power_dpm_force_performance_level = high
```

## How To Reproduce

```bash
# force GPU to high performance
sudo sh -c 'echo high > /sys/class/drm/card1/device/power_dpm_force_performance_level'

# benchmark
llama-bench -m ~/models/bonsai/Bonsai-1.7B.gguf -p 512 -n 128 -ngl 999
llama-bench -m ~/models/bonsai/Bonsai-4B.gguf -p 512 -n 128 -ngl 999
llama-bench -m ~/models/bonsai/Bonsai-8B.gguf -p 512 -n 128 -ngl 999
```

Models available from [PrismML on HuggingFace](https://huggingface.co/PrismML-Eng).

## Warning: Don't Use the Prism ML llama.cpp Fork

We tested the Prism ML llama.cpp fork (build 8656) on the same models. Results:

| | Prism ML Fork | Stock llama.cpp |
|---|---|---|
| **Bonsai 1.7B tg128** | ~5 tok/s | **359 tok/s** |

That's a **70x difference**. The Prism fork's 1-bit Vulkan compute kernels are not optimized for RDNA 3.5. Use stock llama.cpp for Bonsai. Always.

## Where 1-Bit Fits In The Stack

```
FLM              → NPU (Whisper STT, small inference)
llama.cpp Vulkan → GPU (1-bit Bonsai, general inference)  ← this
llama.cpp ROCm   → GPU (ROCm-optimized workloads)
vLLM             → high-throughput serving
```

1-bit models on Vulkan are faster than most people's API calls. Running locally. On 231 MB. No cloud. No API key.

## Comparison: 1-Bit vs Standard Quantization

| Model | Quant | Size | Gen tok/s |
|-------|-------|------|-----------|
| Bonsai 1.7B | Q1_0 (1-bit) | 231 MiB | **359.5** |
| Bonsai 4B | Q1_0 (1-bit) | 540 MiB | **190.1** |
| Bonsai 8B | Q1_0 (1-bit) | 1.07 GiB | **122.0** |
| Qwen3 8B | Q4 | ~5 GiB | 90.0 |
| Qwen3-Coder-30B-A3B | Q4_K_M | ~18 GiB | 73.0 |
| Gemma 4 27B | Q4 | ~16 GiB | 52.4 |

1-bit trades some quality for massive speed and tiny footprint. For coding assistance, quick lookups, and real-time chat — the tradeoff is worth it. For deep reasoning, use the bigger Q4 models.

---

> *"faster, faster, until the thrill of speed overcomes the fear of death."* — Hunter S. Thompson

**[← Back to Wiki Home](Home.md)** · **[Benchmarks →](Benchmarks.md)** · **[NPU Acceleration →](NPU-Acceleration.md)** · **[Bleeding Edge →](Blog-2026-04-13-Bleeding-Edge-Is-Live.md)**
