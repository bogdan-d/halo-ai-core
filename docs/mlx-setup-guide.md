# MLX setup guide (optional path)

> **tl;dr — MLX is NOT the default path for halo-ai.** rocm-cpp is.
> this guide exists so you know *why*, and how to wire MLX up anyway
> if you want a dense fp16 backend for a model we don't have a
> ternary build for yet.

## why MLX isn't the default

halo-ai targets BitNet-b1.58 2B ternary weights on gfx1151. MLX ROCm
(as of 2026-04) has no ternary quantization mode. BitNet's forward pass
requires 2-bit packed weights + `sudot4` / DP4a throughput on ternary
codes. MLX's matmul path assumes fp16/bf16/int8 — ternary falls off
the dispatch table.

we tried:

1. built MLX from source against ROCm 7.13, gfx1151 target, wave32
2. ran BitNet-b1.58-2B weights through MLX quantize API → no ternary
   path exists; closest is int4 group-quant (2× larger, worse quality)
3. attempted to hot-patch a ternary dequant kernel → MLX graph compiler
   rejected the op; would need a full fork + upstream PR

**conclusion:** MLX is great for dense Llama-family fp16 inference on
Apple Silicon. On AMD Strix Halo with ternary, it's a regression vs a
native HIP kernel. rocm-cpp was written because this gap has no fix
short of a multi-week upstream effort.

## when MLX still makes sense

- you're running a **dense fp16 or int4 model** we don't ship a ternary
  build for (SDXL diffusion, whisper, kokoro, some Qwen / Mistral /
  Phi dense variants)
- you want **provider routing** — use it through the `sommelier`
  specialist in agent-cpp with your own API key as one of several
  backends
- you want to **benchmark** the rocm-cpp numbers against MLX directly
  — `docs/benchmark-comparison.md` has the harness

## install (optional)

MLX is NOT installed by `install.sh`. Opt in:

```
# install-source.sh path only — the pre-built install-strixhalo.sh
# ships rocm-cpp binaries and skips MLX.
./install-source.sh --with-mlx
```

This fetches `mlx-rocm` from HEAD, builds against the same TheRock
tree rocm-cpp uses, installs into `/opt/halo-ai/mlx/`, and wires a
systemd user unit `halo-mlx.service` on :8081.

## usage

Point clients at the MLX endpoint:

```bash
curl http://127.0.0.1:8081/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"model":"dense-fp16","messages":[{"role":"user","content":"hi"}]}'
```

Route via sommelier (agent-cpp) by setting in your agent config:

```toml
[[provider]]
name    = "mlx-local"
backend = "openai-compat"
url     = "http://127.0.0.1:8081/v1"
```

## comparison shape

| workload | rocm-cpp (default) | MLX (optional) |
|---|---|---|
| BitNet-b1.58 2B ternary decode | **yes, 83 tok/s @ 64 ctx (68.6 @ 1024), 1.1 GiB** | no ternary path |
| Dense Llama/Qwen fp16 decode | not supported (out of scope) | yes |
| SDXL / diffusion | **yes** — native-HIP port (`halo-sd` on :8081, Caddy `/sd/*`) | yes (`mlx-image`) |
| Whisper STT | yes — `halo-whisper` on :8082 (echo_ear) | yes (`mlx-whisper`) |
| Kokoro TTS | yes — `halo-kokoro` on :8083 (echo_mouth, Bun shim) | yes |

## what killed MLX as the primary backend, in one paragraph

MLX is a clean abstraction layer between PyTorch-like ops and backend
hardware. That abstraction is exactly what we didn't want: halo-ai's
value is the *specific* wave32 WMMA kernel path for ternary on
gfx1151. We'd have been writing a custom MLX backend module to wrap our
HIP kernels for MLX to then dispatch through — adding an indirection
layer over native speed. rocm-cpp is that indirection collapsed.

## porting note

If MLX ships ternary (likely inevitable — BitNet is too big to ignore),
the sommelier routing lets you flip halo-ai's default backend with one
TOML line. halo-1bit `.h1b` files are independent of the runtime — any
engine that speaks ternary can consume them.

### the exo-explore/mlx-bitnet prototype

[exo-explore/mlx-bitnet](https://github.com/exo-explore/mlx-bitnet) is a
prototype BitNet 1.58 implementation for MLX on **Apple Silicon only**.
Not ROCm. Not gfx1151. If halo-ai ever ports to Mac, this is the nearest
starting point — the `.h1b` loader would plug into MLX's array ops via
this project's quant routines. Forked at
[stampby/mlx-bitnet](https://github.com/stampby/mlx-bitnet) as a
frozen reference so the port path stays available if upstream drifts.

Status of upstream as of 2026-04: 17 commits, 1 contributor, 270 stars,
roadmap has "optimized kernels / fine-tuning / demo app" still
"In Progress" or "Not Started". Research-grade, not production.

---

*see also:*
- [`docs/benchmark-comparison.md`](benchmark-comparison.md) — reproducible rocm-cpp vs MLX numbers
- [`docs/replicate.md`](replicate.md) — building from source
- [`docs/rollback-recovery.md`](rollback-recovery.md) — if MLX install breaks something
