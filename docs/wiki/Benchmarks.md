# Benchmarks

Performance numbers on AMD Strix Halo (Ryzen AI MAX+ 395, 128GB unified, gfx1151).

*"Show me what you got."* — Rick Sanchez

## Lemonade v10.2.0 + ROCm (current stable)

Benchmarks run through Lemonade SDK API by Claude Code. No manual tuning — `install.sh --yes-all` applies all optimizations automatically.

**Stack:** Lemonade v10.2.0 → llama.cpp (ROCm) → gfx1151
**VRAM used:** 18.1GB / 64GB

### Qwen3-Coder-30B-A3B (Q4_K_M) — MoE, 3B active params

| Test | Prompt tok | Gen tok | Prompt tok/s | Gen tok/s | TTFT | Total |
|------|-----------|---------|-------------|----------|------|-------|
| Short | 13 | 256 | 251.7 | **73.0** | 52ms | 3.5s |
| Medium | 75 | 512 | 494.3 | **72.5** | 152ms | 7.1s |
| Long | 39 | 1024 | 385.9 | **71.9** | 101ms | 14.2s |
| Sustained | 54 | 2048 | 437.0 | **70.5** | 124ms | 29.0s |

Key observations:
- Rock solid 70-73 tok/s with zero degradation over 2048 tokens
- Sub-200ms TTFT consistently
- Only 18GB of 64GB VRAM used — room for much larger models
- Avg 14.2ms per token sustained

*Tested 2026-04-08 on kernel 6.19.11-arch1-1*

## LLM Inference (llama.cpp direct)

| Model | Quant | tok/s | Notes |
|-------|-------|-------|-------|
| Qwen3 8B | Q4_K_M | 90.0 | Daily driver |
| Qwen3-30B MoE | Q4_K_M | 84.2 | Best MoE performance (direct) |
| Qwen3.5-35B MoE | Q4_K_M | 60.7 | |
| Gemma 4 27B | Q4_K_M | 52.4 | |
| Bonsai 8B | 1-bit | 103.7 gen | Vulkan beats ROCm pre-built |
| Bonsai 4B | 1-bit | 148.3 gen | Vulkan |
| Bonsai 1.7B | 1-bit | 260.0 gen | Vulkan |

## Image Generation (ComfyUI)

| Model | Time | Resolution |
|-------|------|-----------|
| FLUX | 1.0s | 512x512 |
| SDXL | 34.1s | 1024x1024 |

## Video Generation

| Model | Time | Duration |
|-------|------|---------|
| LTX-Video | 20.6s | ~4s clip |

## NPU (requires kernel 7.0+)

| Model | tok/s | Engine |
|-------|-------|--------|
| Qwen3 0.6B | 95.9 | FastFlowLM |

**Status:** NPU needs kernel 7.0+ for XDNA2 SVA support. Kernel 6.19.x loads amdxdna driver but SVA bind fails. Bleeding edge kernel work tracked in [halo-ai-core-bleeding-edge](https://github.com/stampby/halo-ai-core-bleeding-edge).

## GPU + NPU Simultaneous

- Total tokens: 2098
- Peak temperature: 61°C
- Both running at full speed without throttling

## What Makes It Fast

The install script patches llama.cpp at build time:

- **MMQ kernel fix** ([#21284](https://github.com/ggml-org/llama.cpp/issues/21284)) — corrects register pressure on RDNA 3.5 (mmq_x=48, mmq_y=64, nwarps=4)
- **rocWMMA flash attention** — used for HIP workloads (vLLM, PyTorch), not llama.cpp (Vulkan only)
- **fast math intrinsics** — `__expf()` for MoE routing and SiLU activation
- **HIPBLASLT** — `ROCBLAS_USE_HIPBLASLT=1` doubles prompt processing throughput
- **AOTriton** — `TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1` for 19x attention speedup

## halo-bench — Benchmark Suite

Comprehensive benchmark script included in the repo. Outputs JSON, CSV, and human-readable summary.

```bash
# Full suite — all downloaded models, 3 runs per test
./halo-bench.sh

# Single model, quick mode
./halo-bench.sh -m Qwen3.5-35B-A3B-GGUF -q

# 5 runs for statistical stability, with asciinema recording
./halo-bench.sh -r 5 --record

# Benchmark whatever is currently loaded
./halo-bench.sh --skip-load -q
```

**8 benchmark categories:**

| Category | What it measures |
|----------|-----------------|
| Prompt Processing Scaling | Input throughput at 16–4096 tokens |
| Generation Speed | Sustained output at 50–1000 tokens |
| Context Window Stress | Performance under 1K–16K context |
| Reasoning & Thinking | Math, logic, code analysis, chain-of-thought |
| Code Generation | Python, Rust, Bash, SQL across languages |
| Multi-Turn Conversation | Growing context across 4 turns |
| Instruction Following | JSON output, constrained format, system prompt |
| Concurrency | Sequential vs parallel request throughput |

Results are saved to `bench-results/YYYY-MM-DD_HHMMSS/` with `results.json`, `results.csv`, and `summary.txt`.

See [latest benchmark results](../../bench-results/) in the repo.

### Qwen3.5-35B-A3B — halo-bench results (2026-04-09)

| Test | Gen tok/s | Prompt tok/s | Notes |
|------|----------|-------------|-------|
| Prompt ~16 tokens | 62.5 | 269.5 | Cold prompt |
| Prompt ~256 tokens | 62.7 | 941.6 | Scaling up |
| Prompt ~1024 tokens | 62.0 | **1,270.9** | Peak prompt throughput |
| Generate 50 tokens | 58.0 | 216.3 | Short burst |
| Generate 250 tokens | 57.2 | 219.5 | Medium |
| Generate 500 tokens | **57.0** | 219.6 | Sustained |
| Context ~1024 tokens | 57.0 | 1,006.1 | |
| Context ~4096 tokens | 55.6 | 1,116.7 | |
| Context ~8192 tokens | 54.2 | 1,050.1 | Slight gen slowdown at depth |
| Reasoning: Math | 57.0 | 348.4 | Chain-of-thought |
| Reasoning: Code | 57.0 | 405.1 | |
| Code: Python async | 56.8 | 257.2 | |
| Code: Bash scripting | 56.9 | 288.9 | |

**Memory:** llama-server RSS 5.7GB, RAM delta 73MB during inference.

### Quick one-liner benchmark

```bash
# Through Lemonade API
curl -s http://localhost:13305/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "your-model", "messages": [{"role": "user", "content": "test"}], "max_tokens": 256}' \
  | python3 -c "import json,sys; t=json.load(sys.stdin)['timings']; print(f'Gen: {t[\"predicted_per_second\"]:.1f} tok/s, Prompt: {t[\"prompt_per_second\"]:.1f} tok/s, TTFT: {t[\"prompt_ms\"]:.0f}ms')"

# GPU utilization during inference
watch -n 1 rocm-smi
```

## Notes

- Bonsai 1-bit models: Vulkan backend outperforms ROCm pre-built on generation tok/s
- gfx1100 kernels can be 2-6x faster than gfx1151 on some operations
- AOTriton provides 19x attention speedup for training workloads
- Temperature stays under 65°C under sustained load with good cooling
