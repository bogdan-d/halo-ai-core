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

See [release/KERNELS.md](../release/../KERNELS.md) (wait, actually see
[../../release/KERNELS.md](../../release/KERNELS.md)) for the detailed
contributor guide on submitting community builds.

### 2. agent-cpp HTTP endpoint

Right now the only way to get a message onto the bus from outside the process
is stdin (interactive) or through sentinel (Discord events). We want an HTTP
ingestion point so third-party apps can fire `tool_call`, `remember`, `recall`
etc. without wrapping stdin.

Design sketch:
- New specialist `gateway`
- Listens on `:8081` (OpenAI-compat avoided; we want distinct API surface)
- POST `/bus/:to` with a JSON body → converts to `Message`, emits
- Bearer auth, rate-limited, behind the CVG gate for `tool_call` kinds

See [agent-cpp#issues](https://github.com/stampby/agent-cpp/issues) — open an
issue before starting.

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

OpenWebUI and LibreChat work out of the box as LLM frontends. But there's
no halo-ai-core-specific control panel for managing the 17 specialists,
viewing the scribe hash chain, inspecting CVG denials, etc. A minimal
web dashboard (Bun + plain HTML + fetch) would be a great community
contribution.

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
- **Node.js runtime / Electron UIs.** Use Bun or a native stack.
- **AI art / images in the repo.** Keep commits lean.

## Commit signing

Not required. If you sign, we verify. If you don't, your PR still lands.

## Code of conduct

Don't be a jerk. Bring numbers to arguments. Movie quotes welcome.

— *stamped by the architect*
