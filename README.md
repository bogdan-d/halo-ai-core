<p align="center">
  <img src="assets/logo-ring.svg" alt="Halo AI Core" width="150">
</p>

<h1 align="center">Halo AI Core</h1>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?logo=archlinux&logoColor=white)](https://archlinux.org/)
[![AMD ROCm](https://img.shields.io/badge/ROCm-7.2.1-ED1C24?logo=amd&logoColor=white)](https://rocm.docs.amd.com/)
[![Strix Halo](https://img.shields.io/badge/Strix_Halo-gfx1151-ED1C24?logo=amd&logoColor=white)](https://www.amd.com/en/products/processors/laptop/ryzen-ai-max.html)
[![SSH Only](https://img.shields.io/badge/Security-SSH_Only-red)](docs/SECURITY.md)
[![Self Hosted](https://img.shields.io/badge/Self_Hosted-100%25_Local-purple)](https://github.com/stampby/halo-ai-core)

> Your hardware. Your data. Your rules.
>
> *"I know kung fu." — Neo*

Bare-metal AI platform for AMD Strix Halo. One script installs ROCm, Caddy, llama.cpp, Lemonade SDK, and Gaia SDK. Everything runs as systemd services. Everything auto-restarts. SSH only.

**Designed and built by the architect**

## Install

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --yes-all
```

## What You Get

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

## Philosophy

Every piece snaps in and snaps out. No hard dependencies. No vendor lock-in. No cloud tethers.

The core gives you a foundation. What you build on top is your business — game servers, voice pipelines, distributed storage, SSH mesh. Pull a block and nothing else breaks.

When you control your own software, you control your own destiny.

> *"They get the kingdom. They forge their own keys."*

## Docs

Everything lives in the [wiki](docs/wiki/Home.md):

| Guide | What It Covers |
|-------|---------------|
| [Getting Started](docs/wiki/Getting-Started.md) | Install, verify, first steps |
| [Components](docs/wiki/Components.md) | ROCm, Caddy, llama.cpp, Lemonade, Gaia |
| [Adding a Service](docs/wiki/Adding-a-Service.md) | How to snap in your own lego block |
| [Security](docs/SECURITY.md) | SSH keys only, no exceptions |
| [Model Management](docs/wiki/Model-Management.md) | Load, switch, benchmark models |
| [Agents Overview](docs/wiki/Agents-Overview.md) | The 17 LLM actors |
| [Full Wiki](docs/wiki/Home.md) | 24 pages covering everything |

## Options

```
./install.sh --dry-run        Preview without installing
./install.sh --yes-all        Install everything
./install.sh --status         Check what's running
./install.sh --skip-rocm      Skip any component
./install.sh --help           All options
```

## Requirements

- Arch Linux (bare metal)
- AMD Ryzen AI hardware
- Passwordless sudo

## License

MIT

---

<details>
<summary>Translations</summary>

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
