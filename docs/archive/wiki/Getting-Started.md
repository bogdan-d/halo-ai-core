# Getting Started

## Requirements

- AMD Ryzen AI hardware (Strix Halo / Strix Point)
- Arch Linux (bare metal, not a VM)
- Passwordless sudo for your user
- Internet connection for package downloads

## Install

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core

# Preview what will be installed
./install.sh --dry-run

# Install everything
./install.sh --yes-all

# Verify
./install.sh --status
```

## What Gets Installed

1. **Base packages** — build tools, git, SSH, NetworkManager
2. **ROCm 7.2.1** — GPU compute stack (vLLM, whisper.cpp)
3. **Caddy** — reverse proxy with auto-routing
4. **Python 3.13.12 via pyenv**
5. **llama.cpp** — Vulkan only (h/t u/Look_0ver_There — 13-21% faster than ROCm)
6. **Lemonade Server** — AMD's unified AI backend
7. **Gaia SDK** — agent framework

All components run as systemd services. All auto-restart on failure.

## After Install

Check status:
```bash
./install.sh --status
```

Access services (from any SSH-connected machine):
```bash
ssh strix-halo "curl localhost:8080/health"   # llama.cpp
ssh strix-halo "curl localhost:80"             # Caddy landing
```

## Selective Install

Skip components you don't need:
```bash
./install.sh --yes-all --skip-gaia --skip-lemonade
```
