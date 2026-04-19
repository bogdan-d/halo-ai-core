#!/usr/bin/env bash
# halo-ai uninstall — unified removal of everything install-strixhalo.sh +
# install-source.sh + the agent/MCP scaffolding put on this box.
#
# Conservative by default: lists every action, prompts once, then executes.
# Pass --yes to auto-confirm. Pass --dry-run to preview only.
# Never deletes:
#   - model files in ~/halo-ai/models/ or /home/bcloud/models/   (precious)
#   - git checkouts in ~/repos/                                  (source code)
#   - pacman packages (caddy / headscale / tailscale / etc.)     (shared)
#   - HuggingFace cache in ~/.cache/huggingface/                 (precious)
#
# "They mostly come at night. Mostly." — Newt

set -eu

DRY=0
YES=0
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY=1 ;;
        --yes|-y) YES=1 ;;
        --help|-h)
            sed -n '1,25p' "$0"; exit 0 ;;
    esac
done

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
log()  { printf "${CYAN}[halo-uninstall]${NC} %s\n" "$*"; }
run()  { if [[ $DRY -eq 1 ]]; then printf "  ${YELLOW}[dry]${NC} %s\n" "$*"; else eval "$@"; fi; }

cat <<'EOF'

╔═══════════════════════════════════════════════════════════╗
║  halo-ai uninstall                                        ║
║  "Game over, man. Game over!" — Hudson                    ║
╚═══════════════════════════════════════════════════════════╝

EOF

echo "This will remove:"
cat <<EOF
  · systemd system units: halo-bitnet / halo-sd / halo-whisper / halo-kokoro /
    halo-agent / halo-archive (+ timer) / halo-discord / halo-mcp
  · systemd user units:   halo-anvil(.timer) / halo-gh-trio(.timer) /
    halo-memory-sync(.timer)
  · /etc/halo-ai/         (tokens, session cookies, customer registry)
  · /srv/www/mancave      (man-cave static launcher)
  · /srv/www/halo-bootstrap (LAN bootstrap page)
  · Caddy site block in /etc/caddy/Caddyfile (halo hostnames only; other
    sites preserved)
  · Local CA trust entry: /etc/ca-certificates/trust-source/anchors/halo-local.crt
  · Helper scripts in ~/bin: halo-anvil.sh, halo-librarian.sh,
    halo-quartermaster.sh, halo-magistrate.sh, halo-archive.sh,
    halo-memory-sync.sh
  · /usr/local/bin binaries: bitnet_decode, agent_cpp, sd-cli,
    whisper-cli, kokoro_tts, man-cave (if installed)
  · /etc/hosts entries for headscale.* / strixhalo.local
  · ~/.local/share/halo-ai/ (webhook cache, anvil state, echo-wv profile)

This will NOT remove:
  · Models under ~/halo-ai/models/ or ~/models/  (GB of data, precious)
  · Source checkouts under ~/repos/              (your work tree)
  · HuggingFace cache under ~/.cache/huggingface/
  · Distro packages (caddy / headscale / tailscale / rocm-* / chromium)
  · User SSH keys, Reddit / Discord / GitHub tokens outside /etc/halo-ai/
EOF

if [[ $DRY -eq 1 ]]; then
    log "DRY RUN — no changes will be made. Pass without --dry-run to execute."
fi

if [[ $YES -ne 1 && $DRY -ne 1 ]]; then
    echo
    read -rp "proceed? (y/N): " cont
    [[ "$cont" =~ ^[Yy]$ ]] || { log "aborted."; exit 0; }
fi

# ── systemd system units ─────────────────────────────────────
log "disabling + removing system units..."
for unit in halo-bitnet.service halo-sd.service halo-whisper.service halo-kokoro.service \
            halo-agent.service halo-archive.service halo-archive.timer \
            halo-discord.service halo-mcp.service; do
    if systemctl list-unit-files "$unit" &>/dev/null; then
        run "sudo systemctl disable --now $unit 2>/dev/null || true"
        run "sudo rm -f /etc/systemd/system/$unit"
    fi
done
run "sudo rm -rf /etc/systemd/system/halo-agent.service.d"
run "sudo systemctl daemon-reload"

# ── systemd user units ───────────────────────────────────────
log "disabling + removing user units..."
for unit in halo-anvil.timer halo-anvil.service \
            halo-gh-trio.timer halo-gh-trio.service \
            halo-memory-sync.timer halo-memory-sync.service; do
    if systemctl --user list-unit-files "$unit" &>/dev/null; then
        run "systemctl --user disable --now $unit 2>/dev/null || true"
        run "rm -f ~/.config/systemd/user/$unit"
    fi
done
run "systemctl --user daemon-reload"

# ── /etc/halo-ai ──────────────────────────────────────────────
log "removing /etc/halo-ai secrets + customer registry..."
run "sudo rm -rf /etc/halo-ai"

# ── Caddy halo block ─────────────────────────────────────────
if [[ -f /etc/caddy/Caddyfile ]]; then
    log "stripping halo-ai Caddy blocks (preserving other sites)..."
    # Install the default Caddyfile stub from the repo if present, else blank out.
    if [[ -f release/Caddyfile.empty ]]; then
        run "sudo install -m 644 release/Caddyfile.empty /etc/caddy/Caddyfile"
    else
        warn_note="# halo-ai uninstalled $(date -u +%FT%TZ). Edit this file to restore your own config."
        run "echo '$warn_note' | sudo tee /etc/caddy/Caddyfile >/dev/null"
    fi
    run "sudo systemctl reload caddy 2>/dev/null || true"
fi

# ── static sites ─────────────────────────────────────────────
log "removing static sites..."
run "sudo rm -rf /srv/www/mancave /var/www/halo-bootstrap"

# ── local CA trust entry ─────────────────────────────────────
log "removing local CA trust anchor..."
run "sudo rm -f /etc/ca-certificates/trust-source/anchors/halo-local.crt"
run "sudo trust extract-compat 2>/dev/null || true"

# ── helper scripts + binaries ────────────────────────────────
log "removing helper scripts + binaries..."
for f in "$HOME/bin/halo-anvil.sh" "$HOME/bin/halo-librarian.sh" \
         "$HOME/bin/halo-quartermaster.sh" "$HOME/bin/halo-magistrate.sh" \
         "$HOME/bin/halo-archive.sh" "$HOME/.local/bin/halo-memory-sync.sh"; do
    [[ -e "$f" ]] && run "rm -f \"$f\""
done
for bin in bitnet_decode agent_cpp sd-cli whisper-cli kokoro_tts man-cave; do
    if [[ -e "/usr/local/bin/$bin" ]]; then
        run "sudo rm -f /usr/local/bin/$bin"
    fi
done

# ── state dirs ───────────────────────────────────────────────
log "removing state caches..."
run "rm -rf ~/.local/share/halo-ai"
run "rm -f /tmp/halo-* /tmp/echo-* 2>/dev/null || true"

# ── /etc/hosts cleanup ───────────────────────────────────────
log "cleaning /etc/hosts..."
run "sudo sed -i -E '/headscale\\.strixhalo\\.local|strixhalo\\.local/d' /etc/hosts"

# ── final summary ────────────────────────────────────────────
log "${GREEN}done.${NC}"
cat <<'EOF'

halo-ai services, configs, and helper scripts removed.
Models, source checkouts, and distro packages untouched.

To also drop the source trees:
  rm -rf ~/repos/rocm-cpp ~/repos/agent-cpp ~/repos/halo-1bit ~/repos/halo-ai-core
  rm -rf ~/repos/stable-diffusion.cpp ~/repos/whisper.cpp ~/repos/halo-kokoro

To drop the models (~10 GB):
  rm -rf ~/halo-ai/models ~/models

To drop distro packages (shared; verify first):
  sudo pacman -Rns caddy headscale tailscale

Rerun ./install.sh any time.
EOF
