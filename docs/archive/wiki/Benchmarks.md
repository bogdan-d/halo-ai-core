# Benchmarks

*"Show me what you got."* — Rick Sanchez

All numbers verified on AMD Strix Halo (Ryzen AI MAX+ 395, 128GB unified, gfx1151). Reproducible — clone the repo, run `install.sh --yes-all`, load an LLM model in Lemonade, run `bench-kernel.sh`.

---

## The Numbers

**Stack:** Arch Linux → Lemonade Server 10.2.0 → llama.cpp Vulkan *(h/t u/Look_0ver_There)* → gfx1151
**Rotation:** 5 days of results kept. Oldest auto-deleted by `bench-kernel.sh`.

### 2026-04-12: Kernel 6.19.11, Lemonade lemonade version 10.2.0

**Model:** Qwen3-30B-A3B-GGUF | **Governor:** performance | **GPU:** Radeon 8060S Graphics

| Test | Prompt t/s | Gen t/s | TTFT | Total |
|------|-----------|---------|------|-------|
| Short Burst | 193.5 | **165.2** | 68ms | 53ms |
| Medium Response | 136.6 | **89.5** | 37ms | 901ms |
| Long Generation | 135.5 | **88.1** | 57ms | 5869ms |
| Sustained 2K | 212.3 | **84.6** | 79ms | 24280ms |
| Code Gen | 168.0 | **87.2** | 77ms | 10186ms |
| Reasoning | 146.1 | **89.2** | 58ms | 1624ms |
| Long Context | 526.9 | **87.3** | 121ms | 5983ms |

### Synthetic Benchmarks (bench-kernel.sh, averaged over 2-3 runs)

| Test | Prompt tok/s | Gen tok/s | TTFT | Total |
|------|-------------|----------|------|-------|
| Short Burst (24→2) | 193.5 | **165.2** | 68ms | 53ms |
| Medium Response (24→79) | 136.6 | **89.5** | 37ms | 901ms |
| Long Generation (37→512) | 135.5 | **88.1** | 57ms | 5.9s |
| Sustained 2K (51→2048) | 212.3 | **84.6** | 79ms | 24.3s |
| Code Generation (37→892) | 168.0 | **87.2** | 77ms | 10.2s |
| Reasoning (40→156) | 146.1 | **89.2** | 58ms | 1.6s |
| Long Context (223→512) | 526.9 | **87.3** | 121ms | 6.0s |

**Takeaway:** 84-89 tok/s generation, rock solid, zero degradation over 2048 tokens. Sub-100ms TTFT.

### Real-World Queries (actual prompts, actual responses)

| Task | Prompt tok/s | Gen tok/s | TTFT | Tokens |
|------|-------------|----------|------|--------|
| Bug Fix (debug a real error) | 371.5 | **88.6** | 178ms | 256 |
| Code Review (find SQL injection) | 439.7 | **87.8** | 177ms | 512 |
| System Admin (write systemd unit) | 384.0 | **88.4** | 159ms | 354 |
| Explain Like I'm 5 (ROCm vs CUDA) | 321.5 | **88.1** | 156ms | 512 |
| Quick Answer (Q4_K_M vs Q4_0) | 223.4 | **88.7** | 148ms | 256 |

**Takeaway:** Same 87-89 tok/s on real tasks. Not cherry-picked synthetic prompts — actual questions you'd ask.

*Thanks to u/Queasy_Asparagus69 for suggesting real-world queries alongside benchmarks.*

---

## Community Comparison

Same hardware (Strix Halo 395, 128GB), same model (Qwen3.5-35B-A3B Q4_K_M), different setup:

| Setup | Gen tok/s | Backend | Kernel |
|-------|----------|---------|--------|
| **halo-ai-core (this repo)** | **84-89** | Lemonade Vulkan | 6.19.11 |
| kyuz0 toolboxes (vulkan-radv) | 69 | llama-bench | 7.0-rc7 CachyOS |
| kyuz0 toolboxes (vulkan-amdvlk) | 59 | llama-bench | 7.0-rc7 CachyOS |

20-30% faster with Lemonade's Vulkan backend on kernel 6.19. Community data from [kyuz0/amd-strix-halo-toolboxes](https://github.com/kyuz0/amd-strix-halo-toolboxes) — 25 models, 150 benchmarks, 12 hours of testing. [Full spreadsheet](https://docs.google.com/spreadsheets/d/1NzZC4JShGluwH2fdjlMbZ2ke99AcTctUnM7rG12_cYE/) | [llama.cpp discussion](https://github.com/ggml-org/llama.cpp/discussions/20969#discussioncomment-16528183)

---

## Other Models (llama.cpp Vulkan via Lemonade)

| Model | Quant | Gen tok/s | Notes |
|-------|-------|----------|-------|
| Qwen3 8B | Q4_K_M | 90.0 | Daily driver |
| Qwen3-30B MoE | Q4_K_M | 84.2 | |
| Qwen3.5-35B MoE | Q4_K_XL | 84-89 | Current default |
| Gemma 4 27B | Q4_K_M | 52.4 | |
| Bonsai 8B | 1-bit | 103.7 | Vulkan |
| Bonsai 4B | 1-bit | 148.3 | Vulkan |
| Bonsai 1.7B | 1-bit | 260.0 | Vulkan |

## Image Generation (ComfyUI)

| Model | Time | Resolution |
|-------|------|-----------|
| FLUX | 1.0s | 512x512 |
| SDXL | 34.1s | 1024x1024 |

## Video Generation

| Model | Time | Duration |
|-------|------|---------|
| LTX-Video | 20.6s | ~4s clip |

## NPU (kernel 7.0+ stable)

| Model | tok/s | Engine |
|-------|-------|--------|
| Qwen3 0.6B | 95.9 | FastFlowLM |
| Gemma3 1B | 34.9 | FLM |
| Gemma3 4B | 17.0 | FLM |
| DeepSeek-R1 8B | 10.5 | FLM |

NPU runs independently from GPU — zero GPU memory used. For always-on agents while GPU handles big models. Kernel 7.0+ mainline required.

## System Benchmarks

| Test | Result |
|------|--------|
| CPU (sysbench 32t, prime 50000) | 10,328 events/sec |
| Memory bandwidth (sysbench 16t) | 87,088 MiB/sec |
| NVMe read (fio 4K random) | 569K IOPS, 2,224 MiB/s |
| NVMe write (fio 4K random) | 569K IOPS, 2,223 MiB/s |
| NVMe p99 latency | 5 μs |
| GPU + NPU simultaneous | 2,098 tokens, peak 61°C |

---

## Run Your Own

```bash
# Synthetic benchmarks (7 tests, averaged)
./bench-kernel.sh

# Quick one-liner through Lemonade API
curl -s http://localhost:13305/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "your-model", "messages": [{"role": "user", "content": "test"}], "max_tokens": 256, "chat_template_kwargs": {"enable_thinking": false}}' \
  | python3 -c "import json,sys; t=json.load(sys.stdin)['timings']; print(f'Gen: {t[\"predicted_per_second\"]:.1f} tok/s, Prompt: {t[\"prompt_per_second\"]:.1f} tok/s, TTFT: {t[\"prompt_ms\"]:.0f}ms')"

# Full suite with halo-bench
./halo-bench.sh

# GPU utilization during inference
watch -n 1 rocm-smi
```

Raw benchmark JSON files in [`bench-results/`](../../bench-results/).

---

*"That'll do, pig. That'll do." — Babe*

*Designed and built by the architect.*
