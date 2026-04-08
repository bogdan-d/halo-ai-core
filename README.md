<div align="center">

🌐 **English** | [Français](#translations) | [Español](#translations) | [Deutsch](#translations) | [Português](#translations) | [日本語](#translations) | [中文](#translations) | [한국어](#translations) | [Русский](#translations) | [हिन्दी](#translations) | [العربية](#translations)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### the bare-metal ai foundation for amd strix halo

**5 core services · 128gb unified · compiled from source · zero cloud · lego blocks**

*stamped by the architect*

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=archlinux&logoColor=white)](https://archlinux.org)
[![ROCm](https://img.shields.io/badge/ROCm_7.2.1-ED1C24?style=flat&logo=amd&logoColor=white)](https://rocm.docs.amd.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Discord](https://img.shields.io/badge/Discord-halo--ai-5865F2?style=flat&logo=discord&logoColor=white)](https://discord.gg/dSyV646eBs)
[![Wiki](https://img.shields.io/badge/Wiki-24_pages-00d4ff?style=flat&logo=github&logoColor=white)](docs/wiki/Home.md)
[![Medium](https://img.shields.io/badge/Medium-articles-000000?style=flat&logo=medium&logoColor=white)](https://medium.com/@stampby)
[![YouTube](https://img.shields.io/badge/YouTube-tutorials-FF0000?style=flat&logo=youtube&logoColor=white)](https://www.youtube.com/@halo-ai.studio)
[![SSH Only](https://img.shields.io/badge/Security-SSH_Only-red?style=flat)](docs/SECURITY.md)
[![Self Hosted](https://img.shields.io/badge/Self_Hosted-100%25_Local-purple?style=flat)](https://github.com/stampby/halo-ai-core)

</div>

---

> **[wiki](docs/wiki/Home.md)** — 24 pages of docs · **[discord](https://discord.gg/dSyV646eBs)** — community + support · **[tutorials](https://www.youtube.com/@DirtyOldMan-1971)** — video walkthroughs

---

## what is this

the foundation layer for running local ai on your own hardware. one script installs everything. five core services. all systemd. all auto-restart. ssh only. *"i know kung fu."*

## install

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run    # see what happens first
./install.sh --yes-all    # install everything
./install.sh --status     # check what's running
```

## what you get

| | |
|---|---|
| **gpu** | rocm 7.2.1 — full 128gb unified memory on gfx1151 |
| **inference** | llama.cpp — compiled from source, hip + vulkan |
| **backend** | lemonade sdk 9.x — llm, whisper, kokoro, stable diffusion |
| **agents** | gaia sdk 0.17.x — build ai agents that run 100% local |
| **gateway** | caddy 2.x — reverse proxy, drop-in config, auto-routing |

```
┌─────────────────────────────────────────────┐
│                   Caddy (:80)                │
├──────────┬──────────┬───────────┬───────────┤
│ llama.cpp│ Lemonade │   Gaia    │  Your     │
│  :8080   │  :13305  │  agents   │  blocks   │
├──────────┴──────────┴───────────┴───────────┤
│              ROCm 7.2.1 (gfx1151)           │
├─────────────────────────────────────────────┤
│         Arch Linux / systemd / btrfs        │
└─────────────────────────────────────────────┘
```

## philosophy

every piece snaps in and snaps out. no hard dependencies. no vendor lock-in. no cloud tethers.

the ai industry wants you renting someone else's computer. we think you should own the whole stack — the hardware, the models, the data, the pipeline. when you control your own software, you control your own destiny. no api keys expiring at 2am. no terms of service changing under your feet.

this is core. everything else is a lego block you choose to add.

> *"they get the kingdom. they forge their own keys."*

## lego blocks

core is the foundation. snap on what you need:

| block | what it does | status |
|-------|-------------|--------|
| **ssh mesh** | multi-machine networking | [guide →](docs/wiki/SSH-Mesh.md) |
| **voice pipeline** | whisper + kokoro tts | [guide →](docs/wiki/Voice-Pipeline.md) |
| **open webui** | chat frontend | planned |
| **comfyui** | image/video generation | planned |
| **game servers** | arcade management | planned |
| **glusterfs** | distributed storage | planned |
| **discord bots** | ai agents in discord | planned |

[how to build your own block →](docs/wiki/Adding-a-Service.md)

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

built on [llama.cpp](https://github.com/ggml-org/llama.cpp), [Lemonade SDK](https://github.com/lemonade-sdk/lemonade), [AMD Gaia](https://github.com/amd/gaia), [Caddy](https://caddyserver.com), [ROCm](https://github.com/ROCm/TheRock).

---

<div align="center">

*"i am inevitable."* — *stamped by the architect*

MIT

</div>

---

<details>
<summary id="translations">🌐 Translations</summary>

**Français** — Plateforme IA bare-metal pour AMD Strix Halo. Un script. `./install.sh --yes-all`

**Español** — Plataforma de IA bare-metal para AMD Strix Halo. Un script. `./install.sh --yes-all`

**Deutsch** — Bare-Metal-KI-Plattform für AMD Strix Halo. Ein Skript. `./install.sh --yes-all`

**Português** — Plataforma de IA bare-metal para AMD Strix Halo. Um script. `./install.sh --yes-all`

**日本語** — AMD Strix Halo向けベアメタルAIプラットフォーム。`./install.sh --yes-all`

**中文** — AMD Strix Halo裸机AI平台。`./install.sh --yes-all`

**한국어** — AMD Strix Halo용 베어메탈 AI 플랫폼。`./install.sh --yes-all`

**Русский** — Bare-metal AI платформа для AMD Strix Halo. `./install.sh --yes-all`

**العربية** — منصة ذكاء اصطناعي لمعالج AMD Strix Halo. `./install.sh --yes-all`

**हिन्दी** — AMD Strix Halo बेयर-मेटल AI प्लेटफ़ॉर्म। `./install.sh --yes-all`

</details>
