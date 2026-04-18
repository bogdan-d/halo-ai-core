# Architecture

How the four repos fit together.

```
┌─────────────────────────────────────────────────────────────────┐
│  halo-ai-core  (you are here)                                   │
│     install-strixhalo.sh ── pull pre-built binaries from GH     │
│     install-source.sh    ── build everything from source        │
│     iso/ + build-iso.sh  ── make a bootable USB                 │
│     release/              ── build + publish pipeline           │
│     orchestrator/         ── systemd units                      │
└────────┬────────────────────┬───────────────────┬───────────────┘
         │                    │                   │
         ▼                    ▼                   ▼
┌────────────────┐   ┌──────────────────┐   ┌──────────────────┐
│  rocm-cpp      │   │  agent-cpp       │   │  halo-1bit       │
│                │   │                  │   │                  │
│  the engine    │   │  the agents      │   │  the model       │
│  - HIP kernels │   │  - 17 C++ spec-  │   │  - .h1b format   │
│    (gfx1151    │   │    ialists on a  │   │  - .htok tokens  │
│    wave32 WMMA)│   │    message bus   │   │  - QAT + STE     │
│  - .h1b loader │   │  - CVG warden    │   │  - distill from  │
│  - OpenAI HTTP │   │  - hash-chain    │   │    bf16 teachers │
│    server :8080│   │    audit log     │   │  - gguf→h1b      │
│  - SSE stream  │   │  - Discord (w/r) │   │    exporter      │
│                │   │  - GitHub triage │   │                  │
│                │   │  - voice I/O     │   │                  │
│                │   │  - CI runner     │   │                  │
│                │   │  - install-help  │   │                  │
└────────────────┘   └──────────────────┘   └──────────────────┘
```

## Runtime layering

```
┌─────────────────────────────────────────────────────────┐
│            agent-cpp — 17 C++ specialists                │ ← orchestration
├─────────────────────────────────────────────────────────┤
│  rocm-cpp server (:8080) — OpenAI-compat, SSE streaming  │ ← API surface
├─────────────────────────────────────────────────────────┤
│   librocm_cpp — HIP kernels · WMMA wave32 · KV cache    │ ← compute
├─────────────────────────────────────────────────────────┤
│  ternary model (.h1b v2)  ·  halo-1bit tokenizer (.htok) │ ← data
├─────────────────────────────────────────────────────────┤
│          whisper-server (STT) · kokoro (TTS)             │ ← I/O
├─────────────────────────────────────────────────────────┤
│              ROCm 7.13.0  ·  gfx1151 wave32              │ ← driver
├─────────────────────────────────────────────────────────┤
│              Arch Linux · systemd · btrfs                │ ← OS
└─────────────────────────────────────────────────────────┘
```

## Key architectural decisions

### 1. No Python at runtime

Python at training time is fine (halo-1bit/training uses PyTorch). Python at
inference/runtime is a liability on hardware you own — import cost, GC pauses,
GIL, dep hell. `rocm-cpp` and `agent-cpp` are pure C++ with ~5 header-only
dependencies (httplib, nlohmann/json, OpenSSL, FTXUI, usearch).

### 2. No GGML at runtime

rocm-cpp replaces llama.cpp/GGML entirely for the inference path. BitNet's
ternary structure doesn't need GGML's quant family — we load `.h1b` directly
with a memory-mapped, zero-copy loader (~50 LOC) and feed the HIP kernels.

### 3. OpenAI-compat on the front

The server speaks OpenAI's HTTP schema (`/v1/models`, `/v1/chat/completions`
with SSE streaming). This one decision unlocks every frontend in the ecosystem
— OpenWebUI, LibreChat, Continue.dev, Aider, the OpenAI SDKs in Python/Node.
No custom client required.

### 4. Single message bus for agents

agent-cpp's runtime is a simple string-keyed pub/sub. Every specialist gets
one thread, one inbox. Send is non-blocking; handlers run sequentially per
agent (no re-entrancy). Audit tap = a second deliverable to scribe for every
routed message — that's how we get the hash-chained JSONL log for free.

### 5. CVG gate on tools

Borrowed from Edwards 2026 (Convergence Point Theory paper): the warden
specialist enforces four structural checks before any tool invocation —
policy, intent, consent, bounds. Not advisory; calls fail-closed with a
numeric error code. Audit trail gets the denial.

### 6. Release pipeline publishes signed tarballs

Every gfx1151 build is bit-identical. Rebuilding TheRock on every target is
wasted cycles. `release/build-release.sh` produces 4 tarballs; `upload-release.sh`
pushes to GH Releases with a SHA256SUMS file (GPG-signed when a key is set).
`install-strixhalo.sh` verifies before extract. Same chain-of-trust as apt,
pacman, brew — but all our code.

## Threat model

What we DO defend against:

- **Tampering with the audit log** — hash chain breaks on any edit
- **Unauthorized tool invocation** — CVG gate denies
- **Supply chain on release assets** — SHA256 mandatory, GPG when set
- **Cloud data exfiltration** — nothing binds to non-loopback without operator opt-in

What we DON'T claim to defend against:

- **Compromised host OS** — if root is hostile, game over (same as any Linux stack)
- **Hardware attacks** — cold boot, rowhammer, etc. — out of scope
- **Keylog / screen scrape** — a user-space compromise sees everything
- **Model weight exfiltration by legitimate user** — the stack is MIT; if you
  run it, you have the weights. By design.

## Why Strix Halo

128 GB unified memory means we load models up to ~120 GB without swapping or
staging through PCIe. That's the unique angle: a MoE 80B or a 70B dense model
fits comfortably, and ternary 2B fits with 100+ GB of headroom for KV cache
and agent state. No discrete GPU — consumer or datacenter — offers this.

## Why ternary

BitNet-b1.58's ternary weights (−1, 0, +1) let us replace MatMul with
accumulator-only ops. The kernel uses `v_dot4_i8_i8` or `wmma_f16_w32` with
packed ternary operands — 5 tok/s → 85 tok/s vs a generic FP16 matmul on the
same silicon.

## What's next

- **RDNA4 kernel port** (gfx1201 — 9070 XT) — `wmma-256b` → `wmma-512b` rewrite
- **agent_cpp HTTP endpoint** — so external apps can drive the bus (currently
  internal-only or via sentinel/herald)
- **Signed release pipeline** — GPG infrastructure + published pubkey
- **CI on main** — anvil-driven release builds on tag push

See [Contributing](Contributing.md) for how to pitch in.
