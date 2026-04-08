# Changelog

All notable changes to Halo AI Core.

---

## [0.9.0] — 2026-04-08

### Core Services
- ROCm 7.2.1 from Arch repos (gfx1151 + NPU detected)
- Caddy 2.11.2 reverse proxy with drop-in config pattern
- llama.cpp built from source (ROCm HIP + Vulkan, gfx1151)
- Lemonade SDK 9.1.4 with web UI
- Gaia SDK 0.17.1 with Agent UI
- Python 3.13.4 via pyenv (Arch ships 3.14, SDKs need 3.13)

### Web UIs
- Lemonade Server UI on :13305 — chat with LLMs out of the box
- Gaia Agent UI on :4200 — agent management and deployment

### Install Script
- `./install.sh --yes-all` — one command full install
- `./install.sh --dry-run` — preview without installing
- `./install.sh --status` — check what's running
- Skip flags for every component
- Works on fresh Arch install with NetworkManager

### Infrastructure
- All services as systemd units with auto-restart
- Caddy routes via `/etc/caddy/conf.d/*.caddy` drop-ins
- ROCm environment vars in `/etc/profile.d/rocm.sh`
- SSHD hardened: key-only, no passwords, no root

### Documentation
- 29 wiki pages covering full platform
- README in 11 languages
- Security guide, SSH mesh guide, agent deployment specs
- Discord server spec with 18 channels

### GitHub
- CI: syntax check + dry-run + ShellCheck
- CodeQL: weekly security scan
- Dependabot: automated action updates
- Vulnerability alerts enabled
- Issue templates: bug report + feature request
- PR template with checklist
- SECURITY.md, CONTRIBUTING.md

### Assets
- halo-ai logo (circuit halo, server rack, LEDs)
- 7 SVG/PNG logo variants
- Install recording (asciinema cast)

---

*Designed and built by the architect.*
