# halo-ai-core Wiki — the 1-bit monster

Local AI on AMD Strix Halo. No Python at runtime. No cloud. No telemetry. No subscriptions. All C++.

## Start here

- **[Getting-Started](Getting-Started.md)** — install, verify, first chat completion
- **[Architecture](Architecture.md)** — how the three engineering repos fit together
- **[Agents](Agents.md)** — the 17 C++ specialists and what each one does
- **[Integrations](Integrations.md)** — point your apps at the stack (curl, Python, Node, C++, WebUI)
- **[Networking](../NETWORKING.md)** — private mesh (Caddy + Headscale + Tailscale); phone / laptop / multi-node onboarding

## Reference

- **[Benchmarks](Benchmarks.md)** — PPL, KLD, top-1 agreement, decode speed; how to reproduce
- **[Troubleshooting](Troubleshooting.md)** — common failures and their fixes
- **[Contributing](Contributing.md)** — how to add arch coverage, submit community builds, port kernels to non-Strix hardware

## Project shape

```
halo-ai-core         ← you are here. the installer + orchestrator.
├── rocm-cpp         ← the inference engine (HIP, ternary kernels, HTTP server)
├── agent-cpp        ← the agent runtime (17 specialists on a message bus)
└── halo-1bit        ← the model format (.h1b) + training pipeline
```

All four repos MIT-licensed. Everything reproducible from source (`install-source.sh`),
everything fast-installable for Strix Halo (`install-strixhalo.sh`).

> **CachyOS-only for the NPU path.** The XDNA2 NPU on Strix Halo needs the
> `amdxdna` driver patches that ship in CachyOS out of the box. Stock Arch,
> Ubuntu, Fedora, etc. silently fall back to iGPU. See the warning block at
> the top of the [main README](../../README.md).

## Recent improvements (2026-04-19)

| kernel / fix | effect | verified |
|---|---|---|
| RoPE split-half convention | PPL @ 1k wikitext-103: broken → **9.16** (paper baseline) | bit-exact vs HF reference |
| Sherry ternary GEMV (LDS bank-conflict fix) | **1.44–1.66× halo v2** microbench | `max \|halo − sherry\| = 0` |
| TQ1 ternary GEMV (`__builtin_amdgcn_perm` repack) | **1.45–1.66× halo, 197 GB/s** microbench | `max \|halo − tq1\| = 0` |
| Split-KV Flash-Decoding attention | up to **6.78× at L=2048** microbench; **1.83× end-to-end lift at L=1024** (37.5 → 68.6 tok/s) | `max \|fp16 − fd\| < 2e-4` |
| `bitnet_decode --ppl <file>` | teacher-forced PPL harness + wikitext-103 on disk | new in this release |

Post-session end-to-end decode (greedy, bitnet_decode --server):
`N=64 → 83 tok/s · N=256 → 73.5 · N=512 → 71.1 · N=1024 → 68.6`.

## What landed later 2026-04-19 (session-2 delta)

- `bin/halo` unified ops CLI (`halo status / logs / restart / update / doctor / bench`) — see [halo-cli](../halo-cli.md)
- `halo-sd.service` (native HIP SDXL on :8081, Caddy `/sd/*`)
- `halo-whisper.service` on :8082 (echo_ear backend)
- `halo-kokoro.service` on :8083 (Bun TTS shim, echo_mouth backend)
- All halo services migrated from system to user systemd (`~/.config/systemd/user/`)
- `halo-mcp` (C++20 MCP bridge, 17 specialist stubs, Phase 0 live) — [design](../mcp-nexus-design.md)
- `discord-mcp` (Bun MCP server — 17 specialist identities via webhook relay, role management)
- `echo-mcp` (Bun MCP server — reddit posting via cookie-fetch)
- CHANGELOG.md seeded + maintained by `librarian`
- CI workflow simplified (syntax + shellcheck only); uninstall.sh unified

## Movie quotes we live by

- *"I know kung fu."*
- *"they get the kingdom. they forge their own keys."*
- *"there is no cloud. there is only zuul."*
- *"the 1-bit monster is already here. it just had to learn to count."*

— *stamped by the architect*
