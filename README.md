<div align="center">

🌐 **English** | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

# halo-ai core

### the 1-bit monster — local ai inference, bare metal, no python at runtime

**rocm c++ · ternary weights (.h1b) · fused HIP kernels · wave32 wmma · 17 c++ specialists · zero telemetry · zero cloud**

*stamped by the architect*

[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![ROCm](https://img.shields.io/badge/ROCm_7.13-ED1C24?style=flat&logo=amd&logoColor=white)](https://github.com/ROCm/TheRock)
[![rocm-cpp](https://img.shields.io/badge/rocm--cpp-inference_engine-00d4ff?style=flat)](https://github.com/stampby/rocm-cpp)
[![agent-cpp](https://img.shields.io/badge/agent--cpp-17_specialists-00d4ff?style=flat)](https://github.com/stampby/agent-cpp)
[![halo-1bit](https://img.shields.io/badge/halo--1bit-.h1b_format-00d4ff?style=flat)](https://github.com/stampby/halo-1bit)
[![Discord](https://img.shields.io/badge/Discord-halo--ai-5865F2?style=flat&logo=discord&logoColor=white)](https://discord.gg/dSyV646eBs)
[![Reddit](https://img.shields.io/badge/Reddit-r/MidlifeCrisisAI-FF4500?style=flat&logo=reddit&logoColor=white)](https://www.reddit.com/r/MidlifeCrisisAI/)
[![Self Hosted](https://img.shields.io/badge/Self_Hosted-100%25_Local-purple?style=flat)](https://github.com/stampby/halo-ai-core)

</div>

---

## what is this

halo-ai core is the **install script for the 1-bit monster** — a full local AI stack that runs entirely in C++ on AMD Strix Halo hardware. no python at runtime. no cloud. no telemetry. no subscriptions.

> ## ⚠️ You must be running CachyOS. This is not optional.
>
> The XDNA2 NPU on Strix Halo **only works correctly on [CachyOS](https://cachyos.org/)** — the upstream Arch kernel and every other distro we've tested either misses the NPU patches, ships an older `amdxdna` driver, or has `HSA_OVERRIDE_GFX_VERSION` plumbing that silently falls back to CPU. On CachyOS the kernel already carries the fixes we need; on anything else, the NPU loads but inference quietly runs on the iGPU at a fraction of the speed.
>
> **Install CachyOS first.** Then run this script. We do not support Ubuntu, Fedora, Debian, stock Arch, EndeavourOS, or Manjaro for NPU workloads. The GPU path (`rocm-cpp`) technically runs on stock Arch, but you will lose the NPU specialists (`echo_ear`, lemond-FLM backends) and several benchmarks in `bench.sh`.
>
> If `lspci -k | grep -A3 amdxdna` shows the driver bound and you're on kernel `7.0.0-cachyos` or newer — you're good. If not, **go install CachyOS before reading further.** Nothing in this stack will work around a missing NPU driver for you.

one script, three engineering repos:

| repo | what it is |
|------|-----------|
| [**rocm-cpp**](https://github.com/stampby/rocm-cpp) | the inference engine. pure HIP, fused ternary kernels, OpenAI-compatible server with SSE streaming. |
| [**agent-cpp**](https://github.com/stampby/agent-cpp) | the agent framework. 17 single-purpose specialists on a message bus, hash-chained audit log, consent-verification gate. |
| [**halo-1bit**](https://github.com/stampby/halo-1bit) | the model format (.h1b) + training pipeline. absmean ternary, QAT with straight-through estimator, distillation from bf16 teachers. |

halo-ai core clones them, builds them from source, wires them into systemd, and points a caddy reverse proxy at the result. one command, you get a running LLM, a voice loop, a discord bot, a CI runner, and an audit trail. everything local.

*"I know kung fu."*

## install

two paths. the script auto-detects your GPU and picks the right one.

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh                  # auto-dispatch: strixhalo → fast; else → source
```

| path | who it's for | time | what it does |
|------|--------|------|------|
| [`./install-strixhalo.sh`](install-strixhalo.sh) | **gfx1151** (Strix Halo) | ~5 min | downloads pre-built binaries from GH Releases, verifies SHA256 + GPG, wires systemd |
| [`./install-source.sh`](install-source.sh) | any other AMD GPU | ~4 hrs | builds TheRock + rocm-cpp + agent-cpp + halo-1bit from source for your arch |

why two scripts: every Strix Halo is the same silicon (gfx1151, wave32, 128 GB unified). one build produces a binary that runs bit-identically on every such box — no reason to rebuild from source every time. for anything else (gfx1030, gfx1100, gfx1201, CDNA), the wave32 WMMA kernels don't port 1:1, so source build with arch-specific codegen is the safe option.

**running something other than a strix halo and want the kernels built for your GPU?** see [`release/KERNELS.md`](release/KERNELS.md) for arch coverage, how to build your own, and how to share community builds back.

[![Install Demo](https://img.shields.io/badge/asciinema-watch_install_demo-d40000?style=flat&logo=asciinema&logoColor=white)](docs/install-rocmpp.cast)

## the stack

```
┌─────────────────────────────────────────────────────────┐
│            agent-cpp — 17 C++ specialists                │
│   muse · planner · forge · warden (CVG) · scribe         │
│   sommelier · herald · sentinel · carpenter · anvil      │
│   quartermaster · magistrate · librarian · cartograph    │
│   echo_ear · echo_mouth · stdout_sink                    │
├─────────────────────────────────────────────────────────┤
│  rocm-cpp server (:8080) — OpenAI-compat, SSE streaming  │
├─────────────────────────────────────────────────────────┤
│   librocm_cpp — HIP kernels · WMMA wave32 · KV cache    │
├─────────────────────────────────────────────────────────┤
│  ternary model (.h1b v2)  ·  halo-1bit tokenizer (.htok) │
├─────────────────────────────────────────────────────────┤
│          whisper-server (STT) · kokoro (TTS)             │
├─────────────────────────────────────────────────────────┤
│              ROCm 7.13.0  ·  gfx1151 wave32              │
├─────────────────────────────────────────────────────────┤
│              Arch Linux · systemd · btrfs                │
└─────────────────────────────────────────────────────────┘
```

> *every layer is someone else's lego block if they want it. take the whole monster or take one piece.*

## numbers that matter

| metric | value | note |
|---|---|---|
| **decode speed** | 85 tok/s | BitNet-b1.58-2B, greedy, Strix Halo |
| **model size** | 1.1 GiB | TQ1_0 format, 4× smaller than F16 |
| **KLD vs F16** | 0.0023 | mean bits/token — indistinguishable in practice |
| **top-1 agreement** | 96.3% | vs F16 reference, same argmax token |
| **agent binary** | 1.3 MB | agent_cpp, statically linked |
| **cold start** | < 2s | bitnet_decode --server |
| **runtime deps** | 0 python | libc, pthreads, httplib, nlohmann-json, OpenSSL |

details and methodology: [docs/benchmark-comparison.md](docs/benchmark-comparison.md) · [docs/replicate.md](docs/replicate.md)

## what you get

### the engine
- **bitnet_decode** — OpenAI-compatible HTTP server on :8080 with SSE streaming. chat completions, models list, bearer auth optional.
- **`.h1b` loader** — ternary weights, magic `H1B`, 9 int32 config + 2 float32 params. memory-mapped, zero-copy.
- **HIP kernels** — fused ternary MatMul, RMSNorm, SiLU, RoPE. wave32 WMMA. no CK, no hipBLAS at runtime.

### the agents
- **17 specialists** — each one job, each one thread. message bus with tamper-evident journal.
- **consent-verification gate** — warden enforces policy/intent/consent/bounds. structural, not advisory.
- **hash-chained audit log** — every inbound and outbound message SHA-256 chained, genesis-seeded per session.
- **optional plugins** — Discord read (sentinel) + write (herald), GitHub triage/PR-review/docs (quartermaster/magistrate/librarian), CI runner (anvil), install-help (carpenter).

### the model + training
- **halo-1bit** — absmean quantization, QAT with STE, distillation from Qwen3-32B bf16 teacher.
- **.h1b v2 format** — production artifacts shipped with each release.

## lego blocks

pick what you want. drop the rest.

| block | what it does | status |
|-------|------|--------|
| **bitnet_decode** | inference server | required |
| **agent_cpp** | agent framework | required |
| **agent_cpp → sentinel+herald** | Discord bot | optional (set DISCORD_TOKEN) |
| **agent_cpp → echo_ear+echo_mouth** | voice loop | optional (whisper + kokoro services) |
| **agent_cpp → quartermaster/magistrate/librarian** | GitHub automation | optional (set GH_TOKEN) |
| **agent_cpp → anvil** | CI runner | optional |
| **caddy** | reverse proxy + bearer auth | installed + configured |
| **headscale** | self-hosted mesh (Tailscale-compatible) | installed + configured |
| **man-cave TUI** | FTXUI dashboard over SSH | optional (v2) |
| **orchestrator** | systemd unit wiring | included |

## private mesh

halo-ai ships **private-mesh-by-default**. No port forwarding. No SaaS. No cloud dependency.

The install script stands up [Headscale](https://github.com/juanfont/headscale) — a self-hosted, open-source re-implementation of the Tailscale control plane — and enrols the halo box as the first node in its own mesh. Every other device (your laptop, phone, game PC, another halo box) joins by scanning a QR code or running a one-liner the installer prints.

- **Bi-directional full-mesh** — any peer reaches any other peer over WireGuard; no hub-and-spoke.
- **Zero vendor lock-in** — Headscale is OSS, the clients are the standard Tailscale apps on every OS.
- **No keys leave your box** — Headscale stores the coordination state locally in SQLite.
- **Bearer-gated HTTPS** — Caddy terminates TLS with a local CA and enforces an OpenAI-style `Authorization: Bearer ...` token.

Adding a peer (Arch-family):
```bash
curl -fsSL http://<halo-lan-ip>:8099/join.sh | sudo bash
```

Adding a phone: scan the QR code the installer prints → follow the 3-step mobile page → done.

Full walkthrough in **[docs/NETWORKING.md](docs/NETWORKING.md)**.

## philosophy

> every piece snaps in and snaps out. no hard dependencies. no vendor lock-in. no cloud tethers.

python shipped the LLM era. C++ owns the next one. python at training time is fine; python at runtime is a liability on hardware you own. **halo-ai core has zero python at runtime.**

the AI industry wants you renting someone else's computer. we think you should own the whole stack — the hardware, the models, the weights, the pipeline. when you control your own software, you control your own destiny.

*"they get the kingdom. they forge their own keys."*

## privacy

**zero telemetry. zero tracking. zero data collection.** nothing phones home. your data stays on your machine.

paid API providers (OpenAI, Anthropic, Groq, DeepSeek, xAI, OpenRouter) are supported through sommelier with your own keys — but that's your choice, not our default. local-first means local-first.

*"there is no cloud. there is only zuul."*

## docs

| doc | what it covers |
|-----|---|
| [docs/INTEGRATIONS.md](docs/INTEGRATIONS.md) | **point your apps at the stack — openai sdk, curl, python, node, c++, webui, mobile** |
| [docs/NETWORKING.md](docs/NETWORKING.md) | **private mesh — Caddy + Headscale + Tailscale; phone / laptop / multi-node onboarding** |
| [docs/benchmark-comparison.md](docs/benchmark-comparison.md) | reproducible numbers vs llama.cpp / vLLM / MLX |
| [docs/replicate.md](docs/replicate.md) | step-by-step: build the monster on your box |
| [docs/mlx-setup-guide.md](docs/mlx-setup-guide.md) | the MLX path (comparison / optional) |
| [orchestrator/README.md](orchestrator/README.md) | systemd unit wiring |
| [prototypes/](prototypes/) | next-rung experiments (ternary dequant, etc.) |
| [docs/archive/](docs/archive/) | legacy wiki + pre-monster docs |

## options

```
./install.sh --dry-run         preview without installing
./install.sh --yes-all         install everything
./install.sh --status          check what's running
./install.sh --skip-<block>    skip any optional block
./install.sh --help            all options
```

## requirements

- **[CachyOS](https://cachyos.org/) — required for NPU.** See the warning callout at the top; stock Arch and other distros fall back to CPU/iGPU silently.
- AMD Ryzen AI hardware — Strix Halo (gfx1151) or Strix Point (gfx1150)
- kernel `7.0.0-cachyos` or newer with `amdxdna` bound to the NPU (check with `lspci -k | grep -A3 amdxdna`)
- passwordless sudo
- ~20 GiB free disk (build artifacts, kernels, models)

### why CachyOS specifically

- ships the XDNA2 NPU driver patches out of the box (stock Arch kernel lags)
- `rocm-hip-sdk` in `extra` is built against the same LLVM toolchain the release binaries use — no `HSA_OVERRIDE` gymnastics
- limine + btrfs + snapper snapshots for easy rollback if a ROCm upgrade regresses the NPU path
- `gfx1151` is a first-class target in the Cachy community's ROCm tracking

If you want to port to another distro, PRs welcome — but the NPU path will stay CachyOS-only until the NPU patches land upstream.

## credits

this project stands on the shoulders of the people who ship open source.

built on [llama.cpp](https://github.com/ggml-org/llama.cpp) (for eval tooling), [TheRock](https://github.com/ROCm/TheRock) (ROCm distribution), [httplib](https://github.com/yhirose/cpp-httplib), [nlohmann/json](https://github.com/nlohmann/json), [usearch](https://github.com/unum-cloud/usearch), [FTXUI](https://github.com/ArthurSonzogni/FTXUI), [whisper.cpp](https://github.com/ggerganov/whisper.cpp), [Kokoro TTS](https://github.com/remsky/Kokoro-FastAPI), [microsoft/bitnet-b1.58-2B-4T](https://huggingface.co/microsoft/bitnet-b1.58-2B-4T) (reference model).

special thanks to the `r/MidlifeCrisisAI` community for hard questions, especially the ones about PPL and KLD.

---

<div align="center">

*"the 1-bit monster is already here. it just had to learn to count."* — **stamped by the architect**

MIT

</div>
