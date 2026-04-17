# Testing — Clean Room Install Verification

## halo-test-cycle.sh

Automated 8-phase clean room test for the halo-ai-core installer.

### What it does

1. **Preflight** — verifies sudo, install script, basic sanity
2. **Safety check** — confirms SSH keys, network, SSHD survive the nuke
3. **Snapshot** — Btrfs snapshot of current working state (rollback point)
4. **Stop services** — gracefully stops all halo services
5. **Nuke** — deletes `/srv/ai`, `/opt/python312`, `/opt/python313`, temp dirs
6. **Install** — runs `install.sh --yes-all` from scratch, logs everything
7. **Verify** — 22-point post-install check (binaries, services, network, SSH mesh)
8. **Snapshot** — Btrfs snapshot of the new install

### Usage

```bash
# Interactive (asks for confirmation before nuke)
bash scripts/halo-test-cycle.sh

# Fully automated (no prompts)
bash scripts/halo-test-cycle.sh --yes-all
```

### What it checks (Phase 7)

| Check | What |
|-------|------|
| llama-server | HIP binary exists |
| Python 3.12 | Compiled and runnable |
| Python 3.13 | Compiled and runnable |
| Node.js 24 | Compiled and in PATH |
| Rust | Toolchain installed |
| Go | Toolchain installed |
| Caddy | Caddyfile exists |
| llama.cpp | Vulkan build |
| Lemonade | Repo and build present |
| Whisper.cpp | Build present |
| Qdrant | Release binary built |
| SearXNG | Installed |
| Open WebUI | Installed |
| SSH key | Survived the nuke |
| Authorized keys | Survived the nuke |
| SSHD | Still running |
| Network | Interface up with IP |
| DNS | Can resolve external hosts |
| SSH mesh | Can reach ryzen, sliger, pi |

### Rollback

If the install breaks, roll back to the pre-test snapshot:

```bash
# Check available snapshots
ls /.snapshots/

# Rollback (replace with your snapshot name)
sudo btrfs subvolume delete /
sudo btrfs subvolume snapshot /.snapshots/pre-test-YYYY-MM-DD_HHMM /
sudo reboot
```

### When to run

- Before every release tag
- After changing `install.sh`
- After kernel upgrades
- When validating hardware changes

Designed and built by the architect.
