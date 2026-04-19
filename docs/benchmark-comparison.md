# Benchmark Comparison — halo-ai vs llama.cpp vs vLLM vs MLX ROCm

**Hardware:** AMD Strix Halo (Ryzen AI MAX+ 395) · gfx1151 · 128 GB unified · 50 TOPS NPU
**OS:** CachyOS (kernel `7.0.0-cachyos` or newer) · ROCm 7.13.0 · wave32 WMMA
**Date:** 2026-04-19

All numbers: **tok/s generation** · 5-run mean · 256-token completions · greedy decode.

---

## Headline — BitNet-b1.58-2B-4T on Strix Halo

This is the one model this project is about. Apples-to-apples on the same
box, same weights, same prompt:

| Backend | Weight format | Model bytes | tok/s @ 64 / 1024 ctx | PPL @ 1k wikitext-103 | Runtime deps |
|---|---|---|---:|---:|---|
| **halo-ai (rocm-cpp)** | TQ1_0 ternary (.h1b v2) | **1.1 GiB** | **83 / 68.6** | **9.16** | **0 python** |
| llama.cpp (Vulkan, Prism fork) | TQ1_0 | 1.1 GiB | ~65 / — | 9.16 (same weights) | python tooling |
| llama.cpp (ROCm HIP) | TQ1_0 | 1.1 GiB | ~55 / — | 9.16 | python tooling |
| MLX ROCm | (no ternary path) | — | — | — | python runtime |
| vLLM ROCm | (no BitNet runtime) | — | — | — | python runtime |

halo-ai context sweep (same box, post-session): `64 → 83.1 · 256 → 73.5 ·
512 → 71.1 · 1024 → 68.6`. Long-context number is **1.83× the pre-session
baseline** (37.5 → 68.6) thanks to split-KV Flash-Decoding becoming the
default attention path.

**The short version:** halo-ai is the only public gfx1151 stack that runs
BitNet-b1.58 ternary end-to-end. MLX ROCm has no ternary mode (closest is
int4 group-quant — 2× larger, worse quality). vLLM doesn't speak BitNet at
all. llama.cpp speaks TQ1_0 but its ROCm kernel is general-purpose; our
fused HIP path trades generality for throughput.

The ternary GEMV alone runs at **~92% of LPDDR5-8000 peak bandwidth**
(measured via rocprof). Further throughput gains are weight-byte reductions
(Sherry 1.25-bit spike, TQ1 in-tree) rather than compute tuning.

---

## Recent improvements (2026-04-19)

| kernel / fix | effect | verified |
|---|---|---|
| **RoPE split-half convention** | PPL @ 1k wikitext-103: broken → **9.16** (paper baseline) | bit-exact vs HF reference |
| Sherry ternary GEMV (LDS bank-conflict fix) | 1.44–1.66× halo v2 microbench | `max |halo − sherry| = 0` |
| TQ1 ternary GEMV (`__builtin_amdgcn_perm` repack) | 1.45–1.66× halo, 197 GB/s microbench | `max |halo − tq1| = 0` |
| Split-KV Flash-Decoding attention | up to **6.78× at L=2048** microbench; **1.83× end-to-end lift at L=1024** (37.5 → 68.6 tok/s) | `max |fp16 − fd| < 2e-4` |
| `bitnet_decode --ppl <file>` | teacher-forced PPL harness + wikitext-103 on disk | new in this release |

RoPE was the big one — our kernel paired `(x[2i], x[2i+1])` (GPT-NeoX
interleaved) instead of the Llama-family `(x[i], x[i + hd/2])` split-half.
Drift was catastrophic past pos ~100. Fix: one-line swap in
`rocm-cpp/src/prim_kernels.hip`.

---

## Cross-backend generation speed (non-BitNet)

Same Strix Halo, various dense models, for context. halo-ai doesn't run
these — these are the backends you'd use *alongside* halo-ai through
`sommelier` routing:

| Model | Size | MLX ROCm | vLLM ROCm | Prism Vulkan (1-bit) | NPU (FLM) |
|-------|------|------:|------:|------:|------:|
| Qwen3-0.6B | 0.6B | **151.2** | 130.6 | — | 94.4 |
| Qwen3-1.7B | 1.7B | **66.4** | 47.1 | — | — |
| Qwen3-4B | 4B | **46.9** | 41.5 (AWQ) | — | — |
| Qwen3-8B | 8B | 21.7 | **22.3** (AWQ) | — | 10.8 |
| Phi-4-mini | 3.8B | **38.3** | 24.9 | — | — |
| Llama-3.2-1B | 1B | — | 110.4 | — | 61.7 |
| Bonsai-1.7B (native 1-bit) | 1.7B | — | — | **136.8** | — |
| Bonsai-8B (native 1-bit) | 8.2B | — | — | **63.8** | — |

Same bench harness as the headline table. MLX wins on most dense Qwen3;
Prism Vulkan's Bonsai (natively-trained 1-bit) is the wildest number here.
None of these backends run BitNet-b1.58 ternary on gfx1151 — that's the
halo-ai-shaped hole they all leave.

---

## NPU (FastFlowLM) — zero GPU impact

| Model | NPU tok/s | TTFT | RAM |
|-------|------:|------:|------:|
| Qwen3-0.6B | 94.4 | 0.46 s | 0.7 GB |
| Llama-3.2-1B | 61.7 | 0.38 s | 1.3 GB |
| Gemma3-1B | 38.9 | 0.53 s | 1.2 GB |
| Llama-3.2-3B | 24.9 | 0.77 s | 2.7 GB |
| Qwen3-8B | 10.8 | 1.28 s | 5.6 GB |

NPU uses **zero GPU memory** — always-on agents, voice, embeddings run on
the XDNA2 NPU while the GPU handles big models. This is the hybrid
advantage of the Ryzen AI MAX+ 395: not competing, complementing. The
`echo_ear` / `echo_mouth` specialists route to the NPU path by default.

---

## The full stack — three engines, one machine

```
┌──────────────────────────────────────────────────────────────────┐
│                  lemonade-nexus (the node system)                 │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │  halo-ai     │  │  MLX ROCm    │  │  NPU (FLM)           │   │
│  │  rocm-cpp    │  │  iGPU        │  │  XDNA2               │   │
│  │              │  │              │  │                      │   │
│  │ BitNet-2B-4T │  │ Qwen3-4B     │  │ Qwen3-0.6B / voice   │   │
│  │ 83 / 68.6    │  │ 46.9 tok/s   │  │ 94.4 tok/s           │   │
│  │ (64 / 1024)  │  │              │  │                      │   │
│  │ TQ1_0 ternary│  │ 4-bit        │  │ FLM int8             │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
│                                                                  │
│  ┌──────────────────────┐  ┌─────────────────────────────────┐   │
│  │  Prism Vulkan        │  │  vLLM ROCm                      │   │
│  │                      │  │                                 │   │
│  │  Bonsai-8B           │  │  Qwen3-8B-AWQ                   │   │
│  │  63.8 tok/s          │  │  22.3 tok/s                     │   │
│  │  native 1-bit        │  │  AWQ                            │   │
│  └──────────────────────┘  └─────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

**Total throughput when all run simultaneously:**
- GPU: halo-ai (BitNet ternary) or MLX/vLLM (dense) — 20–150 tok/s
- NPU: FLM for agents / voice / embeddings — 10–94 tok/s, zero GPU cost
- Vulkan: Prism 1-bit models for fast local inference — 64–137 tok/s

`sommelier` (one of the 17 agent-cpp specialists) routes across these
backends by latency / capability; `lemonade-nexus` does the multi-node
routing for peers across the Headscale mesh.

---

## How to reproduce

Step-by-step guides:
- [docs/replicate.md](replicate.md) — full rebuild from source
- [docs/wiki/Benchmarks.md](wiki/Benchmarks.md) — PPL + KLD harness
- [docs/wiki/Architecture.md](wiki/Architecture.md) — what every layer does

Run `./bench.sh` from the `halo-ai-core` root after install. It auto-detects
which backends are running and produces a CSV + JSON.

---

## Regressions worth flagging

1. **vLLM Qwen3-1.7B**: high variance (2.5–47.7 tok/s, stddev=26). Batch
   scheduling bug at this size.
2. **vLLM load times**: 100–330s for some models (Phi-4-mini 102s, Qwen3.5-4B
   332s). MLX loads in 3–5s. halo-ai loads in < 2s (mmap + no JIT).
3. **vLLM Gemma-3-4b-it / Qwen3.5-0.8B**: load failure.
4. **MLX ROCm BitNet / Falcon-E 1.58-bit**: warmup failure — no WMMA kernel
   path for ternary. This is why rocm-cpp exists.
5. **MLX ROCm >8B models** (32B, 72B, 122B, DeepSeek-V3): fail — memory
   management or kernel compilation timeout.
