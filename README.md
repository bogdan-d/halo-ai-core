<div align="center">

🌐 **English** | [Français](README.fr.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Português](README.pt.md) | [日本語](README.ja.md) | [中文](README.zh.md) | [한국어](README.ko.md) | [Русский](README.ru.md) | [हिन्दी](README.hi.md) | [العربية](README.ar.md)

<picture>
  <img src="assets/halo-ai.svg" alt="halo ai core" width="200">
</picture>

# halo-ai core

### the bare-metal ai foundation for amd strix halo

**5 core services · 128gb unified · compiled from source · zero cloud · lego blocks**

*stamped by the architect*

[![CI](https://github.com/stampby/halo-ai-core/actions/workflows/ci.yml/badge.svg)](https://github.com/stampby/halo-ai-core/actions/workflows/ci.yml)
[![CodeQL](https://github.com/stampby/halo-ai-core/actions/workflows/codeql.yml/badge.svg)](https://github.com/stampby/halo-ai-core/actions/workflows/codeql.yml)
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
| **llm ui** | lemonade web ui — chat with your models instantly (:13305) |
| **agent ui** | gaia agent ui — deploy and manage agents (:4200) |

```
┌─────────────────────────────────────────────┐
│                   Caddy (:80)                │
├──────────┬──────────┬───────────┬───────────┤
│ Lemonade │ Gaia     │ llama.cpp │  Your     │
│ UI :13305│ UI :4200 │   :8080   │  blocks   │
├──────────┴──────────┴───────────┴───────────┤
│              ROCm 7.2.1 (gfx1151)           │
├─────────────────────────────────────────────┤
│         Arch Linux / systemd / btrfs        │
└─────────────────────────────────────────────┘
```

> 🎬 **[watch the full install](halo-ai-core-install.cast)** — clean install recorded on strix halo. clone the repo and run `asciinema play halo-ai-core-install.cast` to watch it in real time.

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

## core UIs — ready out of the box

| ui | port | what it does |
|----|------|-------------|
| **lemonade** | [localhost:13305](http://localhost:13305) | chat with your llms, load models, switch backends |
| **gaia** | [localhost:4200](http://localhost:4200) | deploy agents, manage conversations, agent web ui |

no cli required. install core, open the browser, start talking to your ai.

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

