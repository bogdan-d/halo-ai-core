# Halo AI Core

> Bare-metal AI platform for AMD Strix Halo. One script. Everything works.
>
> *"I know kung fu." — Neo*

**Designed and built by the architect**

---

## Philosophy

Your hardware. Your data. Your rules.

Halo AI Core is built on one principle: **lego blocks**. Every piece snaps in and snaps out. No hard dependencies. No vendor lock-in. No cloud tethers. The core gives you a foundation — what you build on top of it is your business.

Want a game server? Snap it on. Want GlusterFS for distributed storage? Snap it on. Want an SSH mesh across five machines? Snap it on. Want to rip it all out and start over? Pull the block and nothing else breaks.

The AI industry wants you renting someone else's computer. We think you should own the whole stack — the hardware, the models, the data, the pipeline. When you control your own software, you control your own destiny. No API keys expiring at 2 AM. No terms of service changing under your feet. No monthly bill that goes up every quarter.

This is core. Everything else is a lego block you choose to add.

> *"They get the kingdom. They forge their own keys."*

---

## What Is This

Halo AI Core is the foundation layer for running local AI on AMD Ryzen AI hardware. It installs and configures:

| Component | Version | Purpose |
|-----------|---------|---------|
| **ROCm** | 7.2.1 | AMD GPU compute stack |
| **Caddy** | 2.x | Reverse proxy, auto-routing |
| **llama.cpp** | latest | LLM inference (ROCm + Vulkan) |
| **Lemonade SDK** | 9.x | AMD's unified AI backend |
| **Gaia SDK** | 0.17.x | Agent framework |

Everything runs as **systemd services**. Everything auto-restarts. Everything routes through Caddy.

## Demo

Watch the full clean install on an AMD Strix Halo (128GB):

```bash
# Play the recording locally
asciinema play halo-ai-core-install.cast
```

The cast file is included in this repo. Clone and play it to see the full install in real time.

## Quick Start

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --dry-run     # See what happens first
./install.sh --yes-all     # Install everything
./install.sh --status      # Check what's running
```

## Requirements

- Arch Linux (bare metal)
- AMD Ryzen AI hardware (Strix Halo / Strix Point)
- Passwordless sudo
- Internet connection

## Options

```
--dry-run         Show what would be installed
--yes-all         Skip confirmations
--skip-rocm       Skip ROCm
--skip-caddy      Skip Caddy
--skip-llama      Skip llama.cpp
--skip-lemonade   Skip Lemonade SDK
--skip-gaia       Skip Gaia SDK
--status          Show install status
```

## Architecture

```
┌─────────────────────────────────────────────┐
│                   Caddy                      │
│            Reverse Proxy (:80)               │
├──────────┬──────────┬───────────┬───────────┤
│ llama.cpp│ Lemonade │   Gaia    │  Future   │
│  :8080   │  :13305  │  agents   │ services  │
├──────────┴──────────┴───────────┴───────────┤
│              ROCm 7.2.1 (gfx1151)           │
├─────────────────────────────────────────────┤
│         Arch Linux / systemd / btrfs        │
└─────────────────────────────────────────────┘
```

## Services

| Service | Port | Caddy Port | systemd unit |
|---------|------|------------|--------------|
| llama-server | 8080 | 8081 | llama-server.service |
| Lemonade | 13305 | 13306 | lemonade.service |
| Gaia | — | — | gaia.service |
| Caddy | 80 | — | caddy.service |

## Security

**SSH keys only. No exceptions.**

Halo AI Core binds all services to `localhost`. Nothing is exposed to the network. You access everything through SSH.

Read the full security guide: [docs/SECURITY.md](docs/SECURITY.md)

```bash
# Generate a key
ssh-keygen -t ed25519

# Copy to server
ssh-copy-id bcloud@10.0.0.10

# You're in
ssh bcloud@10.0.0.10
```

## License

MIT

---

## Translations

<details>
<summary>🇫🇷 Français</summary>

### Halo AI Core

Plateforme IA bare-metal pour AMD Strix Halo. Un seul script. Tout fonctionne.

**Composants:** ROCm, Caddy, llama.cpp, Lemonade SDK, Gaia SDK

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --yes-all
```
</details>

<details>
<summary>🇪🇸 Español</summary>

### Halo AI Core

Plataforma de IA bare-metal para AMD Strix Halo. Un script. Todo funciona.

**Componentes:** ROCm, Caddy, llama.cpp, Lemonade SDK, Gaia SDK

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --yes-all
```
</details>

<details>
<summary>🇩🇪 Deutsch</summary>

### Halo AI Core

Bare-Metal-KI-Plattform für AMD Strix Halo. Ein Skript. Alles funktioniert.

**Komponenten:** ROCm, Caddy, llama.cpp, Lemonade SDK, Gaia SDK

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --yes-all
```
</details>

<details>
<summary>🇵🇹 Português</summary>

### Halo AI Core

Plataforma de IA bare-metal para AMD Strix Halo. Um script. Tudo funciona.

**Componentes:** ROCm, Caddy, llama.cpp, Lemonade SDK, Gaia SDK

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --yes-all
```
</details>

<details>
<summary>🇯🇵 日本語</summary>

### Halo AI Core

AMD Strix Halo向けベアメタルAIプラットフォーム。スクリプト一つで全て動作。

**コンポーネント:** ROCm、Caddy、llama.cpp、Lemonade SDK、Gaia SDK

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --yes-all
```
</details>

<details>
<summary>🇨🇳 中文</summary>

### Halo AI Core

AMD Strix Halo裸机AI平台。一个脚本，一切就绪。

**组件:** ROCm、Caddy、llama.cpp、Lemonade SDK、Gaia SDK

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --yes-all
```
</details>

<details>
<summary>🇰🇷 한국어</summary>

### Halo AI Core

AMD Strix Halo용 베어메탈 AI 플랫폼. 스크립트 하나로 모든 것이 작동합니다.

**구성요소:** ROCm, Caddy, llama.cpp, Lemonade SDK, Gaia SDK

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --yes-all
```
</details>

<details>
<summary>🇷🇺 Русский</summary>

### Halo AI Core

Bare-metal AI платформа для AMD Strix Halo. Один скрипт. Всё работает.

**Компоненты:** ROCm, Caddy, llama.cpp, Lemonade SDK, Gaia SDK

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --yes-all
```
</details>

<details>
<summary>🇸🇦 العربية</summary>

### Halo AI Core

منصة ذكاء اصطناعي على المعدن مباشرة لمعالج AMD Strix Halo. سكريبت واحد. كل شيء يعمل.

**المكونات:** ROCm، Caddy، llama.cpp، Lemonade SDK، Gaia SDK

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --yes-all
```
</details>

<details>
<summary>🇮🇳 हिन्दी</summary>

### Halo AI Core

AMD Strix Halo के लिए बेयर-मेटल AI प्लेटफ़ॉर्म। एक स्क्रिप्ट। सब कुछ काम करता है।

**घटक:** ROCm, Caddy, llama.cpp, Lemonade SDK, Gaia SDK

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh --yes-all
```
</details>
