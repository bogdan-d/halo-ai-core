#!/bin/bash
# halo-test-cycle.sh — Full clean room install test cycle
# Snapshot → Nuke → Stock kernel → Install → Verify → Snapshot
# Designed and built by the architect
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; exit 1; }
info() { echo -e "  ${CYAN}▸${NC} $1"; }

TIMESTAMP=$(date +%Y-%m-%d_%H%M)
KERNEL=$(uname -r)
SNAPSHOT_PRE="pre-test-${TIMESTAMP}"
SNAPSHOT_POST="post-test-${TIMESTAMP}"
INSTALL_SCRIPT="/tmp/halo-install.sh"
LOG="/tmp/halo-test-cycle-${TIMESTAMP}.log"

echo ''
echo -e "${CYAN}${BOLD}  ┌─────────────────────────────────────────┐${NC}"
echo -e "${CYAN}${BOLD}  │  HALO-AI CLEAN ROOM TEST CYCLE          │${NC}"
echo -e "${CYAN}${BOLD}  │  ${DIM}snapshot → nuke → install → verify${NC}${CYAN}${BOLD}     │${NC}"
echo -e "${CYAN}${BOLD}  └─────────────────────────────────────────┘${NC}"
echo ''
info "Timestamp: ${TIMESTAMP}"
info "Kernel: ${KERNEL}"
info "Log: ${LOG}"
echo ''

# ── Preflight ──────────────────────────────────────
echo -e "${CYAN}━━━ Phase 1: Preflight ━━━${NC}"

[ "$(whoami)" = "root" ] && fail "Don't run as root"
sudo -n true 2>/dev/null || fail "Need passwordless sudo"

# Check install script exists
if [ ! -f "$INSTALL_SCRIPT" ]; then
    # Try to get it from the repo
    if [ -f ~/halo-ai-core/install.sh ]; then
        cp ~/halo-ai-core/install.sh "$INSTALL_SCRIPT"
        chmod +x "$INSTALL_SCRIPT"
        ok "Install script copied from ~/halo-ai-core/"
    else
        fail "No install script at $INSTALL_SCRIPT or ~/halo-ai-core/install.sh"
    fi
else
    ok "Install script: $INSTALL_SCRIPT"
fi

# Verify SSH will survive
echo ''
echo -e "${CYAN}━━━ Phase 2: Pre-nuke safety check ━━━${NC}"
[ -f ~/.ssh/id_ed25519 ] && ok "SSH key exists" || warn "No SSH key — may lose mesh access"
[ -f ~/.ssh/authorized_keys ] && ok "Authorized keys: $(wc -l < ~/.ssh/authorized_keys) entries" || warn "No authorized_keys"
[ -f ~/.ssh/config ] && ok "SSH config: $(grep -c '^Host ' ~/.ssh/config) hosts" || warn "No SSH config"
systemctl is-active sshd >/dev/null 2>&1 && ok "SSHD running" || warn "SSHD not running"

# Check network
ip addr show eno1 2>/dev/null | grep -q 'inet ' && ok "Network: $(ip -4 addr show eno1 | grep inet | awk '{print $2}')" || warn "No network on eno1"
cat /etc/resolv.conf | grep -q nameserver && ok "DNS configured" || warn "No DNS"

# ── Snapshot ───────────────────────────────────────
echo ''
echo -e "${CYAN}━━━ Phase 3: Snapshot current state ━━━${NC}"

if command -v snapper >/dev/null 2>&1; then
    sudo snapper create -d "$SNAPSHOT_PRE" --type pre 2>/dev/null && ok "Snapper snapshot: $SNAPSHOT_PRE"
else
    if [ -d /.snapshots ]; then
        sudo btrfs subvolume snapshot / "/.snapshots/${SNAPSHOT_PRE}" 2>/dev/null && ok "Btrfs snapshot: $SNAPSHOT_PRE"
    else
        sudo mkdir -p /.snapshots
        sudo btrfs subvolume snapshot / "/.snapshots/${SNAPSHOT_PRE}" 2>/dev/null && ok "Btrfs snapshot: $SNAPSHOT_PRE"
    fi
fi

# ── Stop services ──────────────────────────────────
echo ''
echo -e "${CYAN}━━━ Phase 4: Stop all halo services ━━━${NC}"

SERVICES=$(systemctl list-units --type=service --state=running --no-legend | grep -iE 'halo|lemonade|caddy|llama|vllm|webui|whisper|kokoro|comfyui|searx|qdrant|n8n|dashboard|gaia|meek|pipepie' | awk '{print $1}')
if [ -n "$SERVICES" ]; then
    for svc in $SERVICES; do
        sudo systemctl stop "$svc" 2>/dev/null && ok "Stopped $svc" || warn "Failed to stop $svc"
    done
else
    ok "No halo services running"
fi

# ── Nuke ───────────────────────────────────────────
echo ''
echo -e "${CYAN}━━━ Phase 5: Nuke installed stack ━━━${NC}"
echo -e "  ${YELLOW}${BOLD}This will delete /srv/ai, /opt/python312, /opt/python313${NC}"
echo -e "  ${YELLOW}${BOLD}SSH, network, and user config are NOT touched${NC}"

if [ "${1:-}" != "--yes-all" ]; then
    echo ''
    read -rp "  Type 'NUKE' to confirm: " confirm
    [ "$confirm" != "NUKE" ] && fail "Aborted by user"
fi

sudo rm -rf /srv/ai 2>/dev/null && ok "Nuked /srv/ai"
sudo rm -rf /opt/python312 2>/dev/null && ok "Nuked /opt/python312"
sudo rm -rf /opt/python313 2>/dev/null && ok "Nuked /opt/python313"
sudo rm -rf /tmp/halo-python-* /tmp/halo-node-* /tmp/pipepie /tmp/goose 2>/dev/null
ok "Cleaned temp dirs"

# Disable halo systemd units (don't delete — install will recreate)
sudo systemctl disable halo-*.service halo-*.timer 2>/dev/null || true
ok "Disabled halo systemd units"

# ── Install ────────────────────────────────────────
echo ''
echo -e "${CYAN}━━━ Phase 6: Fresh install ━━━${NC}"
info "Running: bash $INSTALL_SCRIPT --yes-all"
info "Logging to: $LOG"
echo ''

bash "$INSTALL_SCRIPT" --yes-all 2>&1 | tee "$LOG"
INSTALL_RC=${PIPESTATUS[0]}

if [ "$INSTALL_RC" -eq 0 ]; then
    ok "Install completed successfully"
else
    fail "Install failed with exit code $INSTALL_RC — check $LOG"
fi

# ── Verify ─────────────────────────────────────────
echo ''
echo -e "${CYAN}━━━ Phase 7: Post-install verification ━━━${NC}"

PASS=0
TOTAL=0

check() {
    TOTAL=$((TOTAL + 1))
    if eval "$2" >/dev/null 2>&1; then
        ok "$1"
        PASS=$((PASS + 1))
    else
        warn "FAIL: $1"
    fi
}

# Core binaries
check "llama-server exists" "[ -f /srv/ai/llama-cpp/build/bin/llama-server ]"
check "Python 3.12" "/opt/python312/bin/python3.12 --version"
check "Python 3.13" "/opt/python313/bin/python3.13 --version"
check "Node.js 24" "node --version | grep -q v24"
check "Rust toolchain" "rustc --version"
check "Go toolchain" "go version"

# Services
check "Caddy config" "[ -f /etc/caddy/Caddyfile ]"
check "llama.cpp Vulkan build" "[ -d /srv/ai/llama-cpp/build ]"
check "Lemonade" "[ -d /srv/ai/lemonade ]"
check "Whisper.cpp" "[ -d /srv/ai/whisper-cpp/build ]"
check "Qdrant" "[ -f /srv/ai/qdrant/target/release/qdrant ]"
check "SearXNG" "[ -d /srv/ai/searxng ]"
check "Open WebUI" "[ -d /srv/ai/open-webui ]"

# Network (survived the install)
check "SSH key intact" "[ -f ~/.ssh/id_ed25519 ]"
check "Authorized keys intact" "[ -f ~/.ssh/authorized_keys ]"
check "SSHD running" "systemctl is-active sshd"
check "Network up" "ip addr show eno1 | grep -q 'inet '"
check "DNS resolves" "getent hosts api.anthropic.com"

# SSH mesh (can we still reach other machines?)
check "SSH → ryzen" "ssh -o ConnectTimeout=5 -o BatchMode=yes ryzen echo OK"
check "SSH → sliger" "ssh -o ConnectTimeout=5 -o BatchMode=yes sliger echo OK"
check "SSH → pi" "ssh -o ConnectTimeout=5 -o BatchMode=yes pi echo OK"

echo ''
echo -e "  ${BOLD}Results: ${PASS}/${TOTAL} checks passed${NC}"

# ── Post-install snapshot ──────────────────────────
echo ''
echo -e "${CYAN}━━━ Phase 8: Post-install snapshot ━━━${NC}"

if command -v snapper >/dev/null 2>&1; then
    sudo snapper create -d "$SNAPSHOT_POST" --type post 2>/dev/null && ok "Snapper snapshot: $SNAPSHOT_POST"
else
    sudo btrfs subvolume snapshot / "/.snapshots/${SNAPSHOT_POST}" 2>/dev/null && ok "Btrfs snapshot: $SNAPSHOT_POST"
fi

# ── Summary ────────────────────────────────────────
echo ''
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  TEST CYCLE COMPLETE${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ''
info "Kernel: $KERNEL"
info "Pre-snapshot: $SNAPSHOT_PRE"
info "Post-snapshot: $SNAPSHOT_POST"
info "Verification: ${PASS}/${TOTAL} passed"
info "Log: $LOG"
echo ''
if [ "$PASS" -eq "$TOTAL" ]; then
    echo -e "  ${GREEN}${BOLD}ALL CHECKS PASSED${NC}"
else
    echo -e "  ${YELLOW}${BOLD}$((TOTAL - PASS)) CHECK(S) FAILED — review above${NC}"
fi
echo ''
echo -e "  ${DIM}To rollback: sudo btrfs subvolume delete / && sudo btrfs subvolume snapshot /.snapshots/${SNAPSHOT_PRE} /${NC}"
echo -e "  ${DIM}Designed and built by the architect${NC}"
echo ''
