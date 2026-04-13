<div align="center">

🌐 **English** | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### the bare-metal ai foundation for amd strix halo

**12 core services · 128gb unified · lemonade + llama.cpp + arcade + nexus · zero cloud · lego blocks**

*stamped by the architect*

[![CI](https://github.com/stampby/halo-ai-core/actions/workflows/ci.yml/badge.svg)](https://github.com/stampby/halo-ai-core/actions/workflows/ci.yml)
[![CodeQL](https://github.com/stampby/halo-ai-core/actions/workflows/codeql.yml/badge.svg)](https://github.com/stampby/halo-ai-core/actions/workflows/codeql.yml)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=archlinux&logoColor=white)](https://archlinux.org)
[![ROCm](https://img.shields.io/badge/ROCm_7.12.0-ED1C24?style=flat&logo=amd&logoColor=white)](https://rocm.docs.amd.com)
[![Lemonade](https://img.shields.io/badge/Lemonade_10.2.0-00d4ff?style=flat&logo=amd&logoColor=white)](https://github.com/lemonade-sdk/lemonade)
[![Kokoro TTS](https://img.shields.io/badge/Kokoro_TTS-ff6b35?style=flat)](https://github.com/remsky/Kokoro-FastAPI)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-halo--ai-5865F2?style=flat&logo=discord&logoColor=white)](https://discord.gg/dSyV646eBs)
[![Wiki](https://img.shields.io/badge/Wiki-24_pages-00d4ff?style=flat&logo=github&logoColor=white)](docs/wiki/Home.md)
[![Medium](https://img.shields.io/badge/Medium-articles-000000?style=flat&logo=medium&logoColor=white)](https://medium.com/@stampby)
[![YouTube](https://img.shields.io/badge/YouTube-tutorials-FF0000?style=flat&logo=youtube&logoColor=white)](https://www.youtube.com/@halo-ai.studio)
[![SSH Only](https://img.shields.io/badge/Security-SSH_Only-red?style=flat)](docs/SECURITY.md)
[![Self Hosted](https://img.shields.io/badge/Self_Hosted-100%25_Local-purple?style=flat)](https://github.com/stampby/halo-ai-core)
[![Bleeding Edge](https://img.shields.io/badge/⚠_Bleeding_Edge-kernel_7.0_+_NPU-ff4444?style=flat)](https://github.com/stampby/halo-ai-core-bleeding-edge)

</div>

---

> **[wiki](docs/wiki/Home.md)** — 24 pages of docs · **[discord](https://discord.gg/dSyV646eBs)** — community + support · **[tutorials](https://www.youtube.com/@DirtyOldMan-1971)** — video walkthroughs

---

## what is this

the foundation layer for running local ai on your own hardware. one script installs everything. eight steps, all systemd, all auto-restart, everything routes through lemonade server on :13305. ssh only. *"i know kung fu."*

## install

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # see what happens first
./install.sh --yes-all    # install everything
./install.sh --status     # check what's running
```

[![Install Demo](https://img.shields.io/badge/asciinema-watch_install_demo-d40000?style=flat&logo=asciinema&logoColor=white)](halo-ai-core-install.cast) *~3 min on strix halo hardware*

## what you get

| | |
|---|---|
| **gpu** | rocm 7.12.0 — full 128gb unified memory on gfx1151 |
| **inference** | llama.cpp (Vulkan) — via lemonade's llamacpp backend. no compile. *(thank you u/Look_0ver_There)* |
| **backend** | lemonade server 10.2.0 — unified router on :13305. openai + anthropic + ollama compatible |
| **voice** | kokoro tts (cpu) + whisper.cpp (vulkan) — speech-to-text and text-to-speech |
| **coding** | claude code — local ai coding agent, launched through lemonade |
| **games** | infinity arcade — ai game generation from text prompts |
| **interview** | interviewer — ai-powered interview practice sessions |
| **benchmarks** | lemonade eval — automated benchmarking and accuracy analysis |
| **mesh vpn** | lemonade nexus — zero-trust wireguard mesh with cryptographic governance |
| **gateway** | caddy 2.x — dashboard + service proxy on :80 |
| **vpn** | wireguard — scan a qr code, access your stack from your phone |
| **dashboard** | glass control panel — model loading, backend picker, live stats, agent management |

```
┌──────────────────────────────────────────────────┐
│                   Caddy (:80)                    │
├──────────────────────────────────────────────────┤
│           Lemonade Server (:13305)               │
│     unified router — all apis, all backends      │
├────────────┬─────────────┬───────────────────────┤
│ llama.cpp  │  whisper.cpp │  kokoro tts          │
│  (Vulkan)  │  (Vulkan)    │  (CPU)               │
├────────────┴─────────────┴───────────────────────┤
│ Claude Code │ Arcade │ Interviewer │ Nexus VPN  │
├───────────────┴─────────────────────┴────────────┤
│              ROCm 7.12.0 (gfx1151)               │
├──────────────────────────────────────────────────┤
│          Arch Linux / systemd / btrfs            │
└──────────────────────────────────────────────────┘
```

> 🎬 **[watch the full install](halo-ai-core-install.cast)** — clean install recorded on strix halo. clone the repo and run `asciinema play halo-ai-core-install.cast` to watch it in real time.

## benchmarks — out of the box

these numbers come from a clean `install.sh --yes-all` on strix halo hardware. no manual tuning. no tricks. the install script applies all optimizations automatically. benchmarks run through lemonade sdk api by claude code.

| model | quant | test | prompt tok/s | gen tok/s | TTFT |
|-------|-------|------|-------------|----------|------|
| qwen3-30B-A3B | Q4_K_M | short (13→256) | **251.7** | **73.0** | 52ms |
| qwen3-30B-A3B | Q4_K_M | medium (75→512) | **494.3** | **72.5** | 152ms |
| qwen3-30B-A3B | Q4_K_M | long (39→1024) | **385.9** | **71.9** | 101ms |
| qwen3-30B-A3B | Q4_K_M | sustained (54→2048) | **437.0** | **70.5** | 124ms |

*rock solid 70-73 tok/s generation with zero degradation over 2048 tokens. 18gb of 64gb vram used. sub-200ms ttft. tested 2026-04-08.*

### what makes it fast

- **lemonade server** — unified router on :13305. openai, anthropic, and ollama compatible. one endpoint for everything.
- **llama.cpp (Vulkan)** — pre-built Vulkan backend via Lemonade. no compile, no patching. runs on any Vulkan GPU. *(h/t u/Look_0ver_There)*
- **kokoro tts** — fast cpu-based text-to-speech. 9 languages.
- **whisper.cpp (Vulkan)** — speech-to-text with gpu acceleration.
- **gfx1151 optimized** — every binary targets your exact silicon. no generic builds.
- **128gb unified memory** — no VRAM wall. load 35B models without blinking.

you don't have to find these. you don't have to configure them. `install.sh` does it for you. that's the point.

## instant mobile access — scan and go

when the install finishes, a qr code appears in your terminal. open the wireguard app on your phone, scan it, and you're connected to your entire ai stack. no port forwarding. no cloud relay. no configuration. just scan and go.

```
  ┌──────────────────────────────────────────┐
  │  SCAN THIS WITH YOUR PHONE               │
  │  WireGuard app → + → Scan from QR Code   │
  └──────────────────────────────────────────┘

         ▄▄▄▄▄▄▄  ▄▄▄▄▄  ▄▄▄▄▄▄▄
         █ ▄▄▄ █ ██▀▄ █  █ ▄▄▄ █
         █ ███ █ ▄▀▀▄██  █ ███ █
                  (your qr here)

  Phone VPN IP: 10.100.0.2
  Lemonade:     http://10.100.0.1:13305
  Gaia:         http://10.100.0.1:4200
```

wireguard vpn. encrypted tunnel. your phone talks directly to your stack over your local network. works from anywhere on your wifi — or anywhere in the world if you forward udp 51820.

> *feature suggested by zach barrow. huge win. bravo.*

## philosophy

every piece snaps in and snaps out. no hard dependencies. no vendor lock-in. no cloud tethers.

the ai industry wants you renting someone else's computer. we think you should own the whole stack — the hardware, the models, the data, the pipeline. when you control your own software, you control your own destiny. no api keys expiring at 2am. no terms of service changing under your feet.

this is core. everything else is a lego block you choose to add.

> *"they get the kingdom. they forge their own keys."*

## integrate with paid services

local first. cloud when you want it. one link, every major ai provider.

<div align="center">

[![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=flat-square&logo=openai&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Anthropic](https://img.shields.io/badge/Anthropic-191919?style=flat-square&logo=anthropic&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Gemini](https://img.shields.io/badge/Gemini-4285F4?style=flat-square&logo=googlegemini&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Azure](https://img.shields.io/badge/Azure_AI-0078D4?style=flat-square&logo=microsoftazure&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Mistral](https://img.shields.io/badge/Mistral-FF7000?style=flat-square&logo=mistral&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Groq](https://img.shields.io/badge/Groq-F55036?style=flat-square&logo=groq&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![OpenRouter](https://img.shields.io/badge/OpenRouter-6467F2?style=flat-square&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Perplexity](https://img.shields.io/badge/Perplexity-20808D?style=flat-square&logo=perplexity&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![ElevenLabs](https://img.shields.io/badge/ElevenLabs-000000?style=flat-square&logo=elevenlabs&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Replicate](https://img.shields.io/badge/Replicate-000000?style=flat-square&logo=replicate&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Cohere](https://img.shields.io/badge/Cohere-39594D?style=flat-square&logo=cohere&logoColor=white)](https://github.com/stampby/halo-ai.services)
[![Stability](https://img.shields.io/badge/Stability_AI-9B59B6?style=flat-square&logoColor=white)](https://github.com/stampby/halo-ai.services)

**[halo-ai.services →](https://github.com/stampby/halo-ai.services)** — integration guides, routing patterns, api key management

</div>

> *"sometimes you gotta run before you can walk."* — halo-ai runs local. paid services are the escape hatch, not the foundation.

## lego blocks

core is the foundation. snap on what you need:

| block | what it does | status |
|-------|-------------|--------|
| **ssh mesh** | multi-machine networking (default, works anywhere) | [guide →](docs/wiki/SSH-Mesh.md) |
| **vlan tagging** | 802.1Q network isolation (requires managed switch) | [guide →](docs/wiki/Network-Layout.md) |
| **voice pipeline** | whisper + kokoro tts | [guide →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | chat frontend | planned |
| **comfyui** | image/video generation | planned |
| **game servers** | Minecraft + LinuxGSM | active |
| **glusterfs** | distributed storage | planned |
| **discord bots** | ai agents in discord | planned |

[how to build your own block →](docs/wiki/Adding-a-Service.md)

## ready out of the box

install core, open the browser, start talking to your ai. no cli required.

## recommended: core agents

core runs without agents. but these five will watch your stack when you're not around.

| agent | job |
|-------|-----|
| **sentinel** | security — scans, monitors, trusts nothing |
| **meek** | auditor — 17-check daily audit, supply chain |
| **shadow** | integrity — ssh keys, file hashes, mesh health |
| **pulse** | monitor — gpu temps, ram, disk, service health |
| **bounty** | bugs — catches errors, auto-creates fix threads |

they're a recommendation, not a requirement. [core agents guide →](docs/wiki/Core-Agents.md)

## security

ssh keys only. no passwords. no open ports. no exceptions. all services on 127.0.0.1. *"you shall not pass."*

```bash
ssh-keygen -t ed25519
ssh-copy-id bcloud@10.0.0.10
```

[full security guide →](docs/SECURITY.md)

## privacy

**zero telemetry. zero tracking. zero data collection.** nothing phones home. your data stays on your machine. *"there is no cloud. there is only zuul."*

## docs

| guide | what it covers |
|-------|---------------|
| [getting started](docs/wiki/Getting-Started.md) | install, verify, first steps |
| [components](docs/wiki/Components.md) | rocm, caddy, llama.cpp, lemonade, gaia |
| [architecture](docs/wiki/Architecture.md) | how the pieces fit together |
| [adding a service](docs/wiki/Adding-a-Service.md) | snap in your own lego block |
| [model management](docs/wiki/Model-Management.md) | load, switch, benchmark models |
| [agents overview](docs/wiki/Agents-Overview.md) | the 17 llm actors |
| [benchmarks](docs/wiki/Benchmarks.md) | performance numbers |
| [troubleshooting](docs/wiki/Troubleshooting.md) | common fixes |
| [full wiki — 24 pages](docs/wiki/Home.md) | everything |

## options

```
./install.sh --dry-run        preview without installing
./install.sh --yes-all        install everything
./install.sh --status         check what's running
./install.sh --skip-rocm      skip any component
./install.sh --help           all options
```

## requirements

- arch linux (bare metal)
- amd ryzen ai hardware (strix halo / strix point)
- passwordless sudo

## credits

this project exists because of the people who built the tools we stand on.

special thanks to [Light-Heart-Labs](https://github.com/Light-Heart-Labs) and [DreamServer](https://github.com/Light-Heart-Labs/DreamServer) — the lighthouse that showed the way. if it wasn't for that project, none of this would exist.

built on [llama.cpp](https://github.com/ggml-org/llama.cpp), [Lemonade SDK](https://github.com/lemonade-sdk/lemonade), [AMD Gaia](https://github.com/amd/gaia), [Caddy](https://caddyserver.com), [ROCm](https://github.com/ROCm/TheRock), [whisper.cpp](https://github.com/ggerganov/whisper.cpp), [Kokoro](https://github.com/remsky/Kokoro-FastAPI), [ComfyUI](https://github.com/comfyanonymous/ComfyUI), [Open WebUI](https://github.com/open-webui/open-webui), [SearXNG](https://github.com/searxng/searxng), [Vane](https://github.com/ItzCrazyKns/Vane), [pyenv](https://github.com/pyenv/pyenv).

---

<div align="center">

*"i am inevitable."* — *stamped by the architect*

MIT

</div>

