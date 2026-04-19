# Contributing

halo-ai-core is MIT-licensed across the board. Fork it, ship it, make money
off it, patch it — the only rule is the rule in the philosophy: **keep the
runtime Python-free**, and be honest about numbers.

## Where to help (in order of highest impact)

### 1. Kernel ports for non-Strix hardware

The fast-install path only ships `gfx1151` binaries today. Everything else
goes through the slow `install-source.sh` path, and some archs (RDNA4,
RDNA2, CDNA) need kernel rewrites because wave-size or WMMA instruction
encoding differs.

Current coverage:

| arch | family | status |
|---|---|---|
| gfx1151 | Strix Halo | **official** — this is the ship target |
| gfx1150 | Strix Point | should cross-compile, untested |
| gfx1100 | RX 7900 XT/XTX, 7800 (RDNA3 dGPU) | community-testable |
| gfx1101 | RX 7700 XT | community-testable |
| gfx1200 | Navi 44 (RX 9060 XT, RDNA4) | needs wmma-512b port |
| gfx1201 | Navi 48 (RX 9070 XT, RDNA4) | needs wmma-512b port |
| gfx1030 | RX 6900/6800 (RDNA2) | no native WMMA — DP4A fallback needed |
| gfx908 / 90a / 942 | CDNA MI100/200/300 | wave64 — different kernel family |

See [release/KERNELS.md](../../release/KERNELS.md) for the detailed
contributor guide on submitting community builds.

### 2. halo-mcp BusBridge (Phase 1)

Right now the only way to get a message onto the bus from outside the process
is stdin (interactive) or through sentinel (Discord events). **halo-mcp**
(`stampby/halo-mcp`, C++20, stdio/JSON-RPC) is Phase 0 live — it registers 17
`<name>_call` MCP tools that today return "not implemented". Phase 1 is the
`BusBridge` that walks MCP `tools/call` → `agent-cpp` Message → awaits reply.

Design is in [`docs/mcp-nexus-design.md`](../mcp-nexus-design.md). The short
version:
- Stdio JSON-RPC (Claude Code / Claude Desktop spawn per session)
- Reuses `libagent_cpp.a` CVG gate + hash-chained audit chain
- Phase 2+ adds nexus federation over the Headscale mesh

A plain agent-cpp HTTP ingest is still an option for callers that don't want
MCP — open an issue before starting either.

### 3. Distillation of a better model

halo-1bit has a full distillation spec. We need someone with time on a big GPU
(40+ GB bf16 for a 32B teacher) to run a 5B-token smoke test from the spec.

See [halo-1bit/docs/16-distillation-spec.md](https://github.com/stampby/halo-1bit/blob/main/docs/16-distillation-spec.md).

### 4. Reproducible builds

Right now `release/build-release.sh` produces binaries that match on the same
host but aren't bit-identical across different hosts (LLVM + ROCm embed
timestamps). Getting to full reproducibility lets us say "prove the binary
matches the source" — a meaningful security property.

Tracking issue: TBD. If you work on build reproducibility, we'd love a PR.

### 5. WebUI / control panel

OpenWebUI and LibreChat work out of the box as LLM frontends. The frosted-glass
**mancave launcher** ships at `https://<host>.local/mancave/` and lists halo
services alongside Lemonade + Gaia tiles, but it's a static launcher — there's
still no halo-ai-core-specific control panel for managing the 17 specialists,
viewing the scribe hash chain, inspecting CVG denials, etc. A minimal web
dashboard (Bun + plain HTML + fetch) would be a great community contribution.

Also of note: **CHANGELOG.md** is now seeded and maintained by the `librarian`
specialist. If you add a feature / kernel / fix, the human-editable touchpoint
is usually the PR body — librarian picks from there.

## Workflow

1. Open an issue describing what you want to change (tag it correctly — the
   quartermaster specialist will auto-classify and reply)
2. Fork the relevant repo (`halo-ai-core`, `rocm-cpp`, `agent-cpp`, or `halo-1bit`)
3. Branch off `main`
4. Commit style: imperative mood, one commit per logical change, `Co-Authored-By`
   if AI-assisted (we do this too)
5. Open a PR — the magistrate specialist will scan for policy issues:
   - No Python in runtime paths (training code is fine)
   - No GPL/AGPL dependencies
   - No MLX/PyTorch imports in runtime code
   - Tests alongside source changes
6. Architect reviews. Magistrate flags are advisory, not blocking.

## Things we won't merge

- **Python at runtime.** Period. (Training code in halo-1bit is the exception
  because it isn't shipped.)
- **Telemetry / analytics / "opt-out" phone-home.** No.
- **Required paid API keys.** Every paid backend must be opt-in via sommelier.
- **Closed-source "enhancement" blobs.** Everything MIT, source included.
- **Node.js runtime / Electron UIs.** Use Bun or a native stack. (Bun is
  explicitly allowed — `halo-kokoro`, `discord-mcp`, and `echo-mcp` all run
  under Bun.)
- **AI art / images in the repo.** Keep commits lean.

## Commit signing

Not required. If you sign, we verify. If you don't, your PR still lands.

## Code of conduct

Don't be a jerk. Bring numbers to arguments. Movie quotes welcome.

— *stamped by the architect*
