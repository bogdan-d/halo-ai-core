# Architecture

How the three engineering repos (plus the `halo-ai-core` orchestrator) fit
together.

```
┌─────────────────────────────────────────────────────────────────┐
│  halo-ai-core  (you are here)                                   │
│     install-strixhalo.sh ── pull pre-built binaries from GH     │
│     install-source.sh    ── build everything from source        │
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
│   peer devices (laptop · phone · other halo boxes)       │ ← consumers
├─────────────────────────────────────────────────────────┤
│   Tailscale client on each peer ─── WireGuard mesh ─     │ ← private net
├─────────────────────────────────────────────────────────┤
│   Headscale control plane (self-hosted, :8380 local)     │ ← coordination
├─────────────────────────────────────────────────────────┤
│   Caddy reverse proxy (:443) — tls internal + bearer     │ ← edge / auth
├─────────────────────────────────────────────────────────┤
│            agent-cpp — 17 C++ specialists                │ ← orchestration
├─────────────────────────────────────────────────────────┤
│  rocm-cpp server (:8080) — OpenAI-compat, SSE streaming  │ ← API surface
├─────────────────────────────────────────────────────────┤
│   librocm_cpp — HIP kernels · WMMA wave32 · KV cache    │ ← compute
├─────────────────────────────────────────────────────────┤
│  ternary model (.h1b v2)  ·  halo-1bit tokenizer (.htok) │ ← data
├─────────────────────────────────────────────────────────┤
│  halo-sd (:8081 SDXL HIP) · halo-whisper (:8082 STT) ·   │
│  halo-kokoro (:8083 TTS, Bun shim)                       │ ← I/O
├─────────────────────────────────────────────────────────┤
│              ROCm 7.13.0  ·  gfx1151 wave32              │ ← driver
├─────────────────────────────────────────────────────────┤
│              Arch Linux · systemd · btrfs                │ ← OS
└─────────────────────────────────────────────────────────┘
```

The top three layers (peers · WireGuard · Headscale) are what `install-strixhalo.sh`
step 7/7 sets up. Peer devices pull a preauth key from the halo box and join the mesh
in one command / one QR scan. Full walkthrough: [Networking](../NETWORKING.md).

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
accumulator-only ops. The kernel uses `__builtin_amdgcn_sudot4` with packed
ternary operands; the service hits **83 tok/s @ 64 ctx / 68.6 tok/s @ 1024 ctx**
steady-state greedy decode on Strix Halo (post-RoPE-fix + split-KV FD default,
2026-04-19). The ternary GEMV alone runs at ~92% of LPDDR5-8000 peak bandwidth.
PPL on wikitext-103 1k window is **9.16** — matching the paper baseline for
BitNet-b1.58-2B-4T.

## Recent improvements (2026-04-19)

| kernel / fix | effect | verified |
|---|---|---|
| RoPE split-half convention | PPL @ 1k wikitext-103: broken → **9.16** (paper baseline) | bit-exact vs HF reference |
| Sherry ternary GEMV (LDS bank-conflict fix) | **1.44–1.66× halo v2** microbench | `max \|halo − sherry\| = 0` |
| TQ1 ternary GEMV (`__builtin_amdgcn_perm` repack) | **1.45–1.66× halo, 197 GB/s** microbench | `max \|halo − tq1\| = 0` |
| Split-KV Flash-Decoding attention | up to **6.78× at L=2048** microbench | `max \|fp16 − fd\| < 2e-4` |
| `bitnet_decode --ppl <file>` | teacher-forced PPL harness + wikitext-103 on disk | new in this release |

## Satellite services (post-session 2026-04-19)

All run under user-systemd alongside `halo-bitnet` / `halo-agent`:

| service | port | role |
|---|---|---|
| halo-sd | 8081 | native-HIP SDXL (zero hipBLAS), Caddy `/sd/*` |
| halo-whisper | 8082 | whisper.cpp STT — echo_ear backend |
| halo-kokoro | 8083 | Bun shim over Kokoro TTS — echo_mouth backend |

Bridges to outside the box (also post-session):

| bridge | what it does | transport |
|---|---|---|
| `halo-mcp` | 17 agent-cpp specialists as JSON-RPC tools (Phase 0 stubs) | stdio |
| `discord-mcp` | 17 specialist identities via Echo webhook relay; roles | stdio (Bun) |
| `echo-mcp` | reddit posting (echo-halo-ai) via cookie-fetch | stdio (Bun) |

See [docs/mcp-nexus-design.md](../mcp-nexus-design.md) for the phased plan and
[docs/INTEGRATIONS.md](../INTEGRATIONS.md) for wiring.

## What's next

- **RDNA4 kernel port** (gfx1201 — 9070 XT) — `wmma-256b` → `wmma-512b` rewrite
- **halo-mcp Phase 1** — BusBridge implementation; specialists reachable via
  MCP instead of stub "not implemented"
- **agent_cpp HTTP endpoint** — so external apps can drive the bus (currently
  internal-only, via sentinel/herald, or via halo-mcp stdio)
- **Signed release pipeline** — GPG infrastructure + published pubkey
- **CI on main** — anvil-driven release builds on tag push

See [Contributing](Contributing.md) for how to pitch in.
