# Rollback recovery — bringing halo-ai back after a snapper rollback

If you rolled back the root subvolume (via limine menu or `snapper rollback`),
follow this runbook. **Total time: ~10 minutes.** All data in `/home` is
untouched — only `/etc`, `/usr`, and installed packages need to be replayed.

## Pre-flight

Verify you're on the expected snapshot:

```sh
uname -r                          # should still show 7.0.0-*-cachyos
cat /etc/os-release | grep ID     # should say cachyos
snapper list | tail -5            # current snapshot at top
```

## Step 1 — restore passwordless sudo (optional, speeds up everything else)

```sh
sudo bash -c 'echo "bcloud ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-bcloud-nopasswd && chmod 440 /etc/sudoers.d/99-bcloud-nopasswd'
```

## Step 2 — re-install the toolchain

Pacman state is on the root subvol, so packages installed after the snapshot
are gone. Everything halo-ai-core needs:

```sh
sudo pacman -Syu --noconfirm --needed \
    base-devel cmake ninja git github-cli bun cmake ninja \
    rocm-hip-sdk rocm-opencl-sdk
```

AUR helper + Chrome (optional, for browsing):

```sh
# paru is often still there; if not:
# sudo pacman -S --noconfirm --needed paru
paru -S --noconfirm --needed google-chrome
```

## Step 3 — re-run the halo-ai install

All of our security + UX fixes are committed upstream. Just pull and run:

```sh
cd ~/repos/halo-ai-core
git pull origin main
./install.sh                    # auto-detects gfx1151 → fast path (~5 min)
```

This will:
- Verify CachyOS (we added the check)
- Install rocm-hip-sdk if needed
- Download the pre-built binaries from GH releases
- Write `/etc/ld.so.conf.d/halo-ai.conf` (the Arch ldconfig fix)
- Symlink the tokenizer path (workaround for bitnet_decode hardcoded path)
- Create + enable **user-scope** systemd units in `~/.config/systemd/user/`:
  `halo-bitnet`, `halo-agent`, and (if opted in) `halo-sd`, `halo-whisper`,
  `halo-kokoro` (migrated from system-scope as of 2026-04-19)
- Drop `bin/halo` onto `$PATH` as the unified ops CLI (`halo status`,
  `halo doctor`, etc.)

## Step 4 — restore secrets

Halo services run under **user-systemd** (post-2026-04-19). Secrets live in
the user config tree, drop-ins in the user unit directory — no `sudo`:

```sh
mkdir -p ~/.config/halo-ai
cat > ~/.config/halo-ai/secrets.env <<'EOF'
DISCORD_TOKEN=
DISCORD_ANNOUNCEMENTS_CHANNEL=
GH_TOKEN=
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
EOF
chmod 600 ~/.config/halo-ai/secrets.env

# user-systemd drop-in to read the file:
mkdir -p ~/.config/systemd/user/halo-agent.service.d
cat > ~/.config/systemd/user/halo-agent.service.d/10-secrets.conf <<EOF
[Service]
EnvironmentFile=-$HOME/.config/halo-ai/secrets.env
EOF

systemctl --user daemon-reload
systemctl --user restart halo-agent
```

Paste real token values into `~/.config/halo-ai/secrets.env` when you want
Discord / GitHub / external LLMs live. If you still have a
`/etc/halo-ai/secrets.env` from the system-scope era, you can either migrate
it (`cp /etc/halo-ai/secrets.env ~/.config/halo-ai/`) or point the
EnvironmentFile= line at that path instead.

## Step 5 — re-authenticate `gh` if needed

```sh
gh auth status || gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git
```

## Step 6 — memory sync timer

The systemd user unit files in `~/.config/systemd/user/` survived (that's
in /home), but systemd's runtime state didn't.

```sh
systemctl --user daemon-reload
systemctl --user enable --now halo-memory-sync.timer
```

Memory will pull from `stampby/claude-memory` on first access — Claude will
recall everything (rules, decisions, project state) automatically.

## Step 7 — verify

```sh
# Full health probe (user-scope units; bitnet/sd/whisper/kokoro/agent)
halo doctor

# Manual equivalent:
systemctl --user status halo-bitnet halo-agent --no-pager | head -20
curl -s http://localhost:8080/v1/models

# MCP server (Phase 0 stubs live at stampby/halo-mcp)
cd ~/repos/halo-mcp
cmake --build build
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | ./build/halo_mcp | head -3

# Memory sync
systemctl --user list-timers halo-memory-sync.timer
```

If all four blocks return clean output, the stack is back to the state
before the rollback.

## Why this works automatically

- **Every fix** I made during the fresh install is committed on GitHub in
  the main branches of stampby/halo-ai-core, rocm-cpp, agent-cpp. Rollback
  doesn't touch GitHub.
- **Claude's memory** is a separate private repo (stampby/claude-memory).
  When Claude starts a fresh session, it reads those files and remembers
  rules, decisions, and project context — no re-explaining needed.
- **Your /home is a different Btrfs subvolume** — rollback never touches it.

The only thing you have to do manually is re-run the install script and
paste secrets. That's 5–10 minutes once you have the runbook open.
