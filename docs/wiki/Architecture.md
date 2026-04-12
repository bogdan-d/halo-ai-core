# Architecture

## Layer Diagram

```
┌─────────────────────────────────────────────┐
│                   Caddy                      │
│            Reverse Proxy (:80)               │
├──────────┬──────────┬───────────┬───────────┤
│ llama.cpp│ Lemonade │   Gaia    │  Future   │
│ (Vulkan) │  :13305  │  agents   │ services  │
├──────────┴──────────┴───────────┴───────────┤
│     Vulkan (llama.cpp) + ROCm (vLLM/whisper)│
├─────────────────────────────────────────────┤
│         Arch Linux / systemd / btrfs        │
└─────────────────────────────────────────────┘
```

## Design Principles

### Lego Blocks
Every component is independent. Remove llama.cpp? Lemonade still works. Remove Gaia? llama.cpp still works. Nothing depends on everything else being there.

### systemd Native
Every service is a systemd unit. `systemctl start`, `systemctl stop`, `systemctl status`. No custom process managers. No Docker. No Kubernetes. Just systemd.

### Caddy as Gateway
All services bind to `localhost`. Caddy is the only thing that could listen externally (and by default it only serves a status page). Drop a `.caddy` file in `/etc/caddy/conf.d/` and Caddy picks it up on reload.

### btrfs Snapshots
The install script is designed to be run on btrfs. Take a snapshot before installing, and if anything goes wrong, roll back in seconds.

### SSH Only
No web panels exposed. No open ports except 22. You SSH in and do everything from the terminal. This is a feature, not a limitation.

## Ports

| Service | Internal Port | Caddy Port | Notes |
|---------|--------------|------------|-------|
| Caddy | 80 | — | Landing page |
| llama.cpp | 8080 | 8081 | OpenAI-compatible API |
| Lemonade | 13305 | 13306 | AMD unified backend |
| Gaia | varies | — | Agent framework |
| SSH | 22 | — | Only external port |

## File Locations

| What | Where |
|------|-------|
| llama.cpp binary | `/usr/local/bin/llama-server` |
| llama.cpp source | `~/llama.cpp/` |
| Lemonade venv | `~/lemonade-env/` |
| Gaia venv | `~/gaia-env/` |
| Gaia source | `~/gaia/` |
| Python 3.13 | `~/.pyenv/versions/3.13.4/` |
| Caddy config | `/etc/caddy/Caddyfile` |
| Caddy drop-ins | `/etc/caddy/conf.d/*.caddy` |
| ROCm | `/opt/rocm/` |
| systemd units | `/usr/lib/systemd/system/` |
| Install log | `/tmp/halo-ai-core-install.log` |
