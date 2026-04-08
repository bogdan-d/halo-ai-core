# Benchmarks

Performance numbers on AMD Strix Halo (Ryzen AI MAX+ 395, 128GB unified, gfx1151).

## LLM Inference (llama.cpp)

| Model | Quant | tok/s | Notes |
|-------|-------|-------|-------|
| Qwen3 8B | Q4_K_M | 90.0 | Daily driver |
| Bonsai 1-bit | 1-bit | 103.7 prompt, 260.0 gen | Vulkan beats ROCm pre-built |
| Qwen3-30B MoE | Q4_K_M | 84.2 | Best MoE performance |
| Qwen3.5-35B MoE | Q4_K_M | 60.7 | |
| Gemma 4 27B | Q4_K_M | 52.4 | |

## Image Generation (ComfyUI)

| Model | Time | Resolution |
|-------|------|-----------|
| FLUX | 1.0s | 512x512 |
| SDXL | 34.1s | 1024x1024 |

## Video Generation

| Model | Time | Duration |
|-------|------|---------|
| LTX-Video | 20.6s | ~4s clip |

## NPU

| Model | tok/s | Engine |
|-------|-------|--------|
| Qwen3 0.6B | 95.9 | FastFlowLM |

## GPU + NPU Simultaneous

- Total tokens: 2098
- Peak temperature: 61°C
- Both running at full speed without throttling

## How to Benchmark

```bash
# Quick LLM benchmark
llama-cli -m ~/models/model.gguf -p "Write a story about a robot" \
    -n 256 --n-gpu-layers 999 2>&1 | grep "eval time"

# GPU utilization during inference
watch -n 1 rocm-smi
```

## Notes

- Bonsai 1-bit models: Vulkan backend outperforms ROCm pre-built on generation tok/s
- gfx1100 kernels can be 2-6x faster than gfx1151 on some operations
- AOTriton provides 19x attention speedup for training workloads
- Temperature stays under 65°C under sustained load with good cooling
