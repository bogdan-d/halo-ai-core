#!/bin/bash
# ============================================================
# Halo AI Core — Uninstall Script
# "You either die a hero, or live long enough to see yourself become the villain." — Harvey Dent
#
# Designed and built by the architect
#
# Removes all Halo AI Core services, configs, and data.
# Does NOT remove ROCm, base system packages, or Caddy itself.
# Models and bench results are kept unless you explicitly remove them.
# ============================================================
set -euo pipefail

VERSION="2.0.0"
USER="${USER:-$(whoami)}"
LOG_DIR="${HOME}/.local/log"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/halo-ai-core-uninstall.log"
touch "$LOG_FILE" && chmod 600 "$LOG_FILE"

# Colors (same as install.sh)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Flags
DRY_RUN=false
YES_ALL=false
KEEP_DATA=false
REMOVE_PYENV=false
REMOVE_MODELS=false

# Tracking
REMOVED=()
SKIPPED=()
ERRORS=()

usage() {
    echo "Halo AI Core v${VERSION} — Uninstall Script"
    echo ""
    echo "Usage: ./uninstall.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run        Show what would be removed without doing it"
    echo "  --yes-all        Skip all confirmation prompts"
    echo "  --keep-data      Preserve user models and benchmark results"
    echo "  --remove-pyenv   Also remove pyenv (~/.pyenv)"
    echo "  --remove-models  Also remove downloaded models (lemonade cache)"
    echo "  -h, --help       Show this help"
    echo ""
    echo "Safe by default:"
    echo "  - Does NOT remove ROCm or base system packages"
    echo "  - Does NOT remove Caddy (pacman package — only removes halo configs)"
    echo "  - Does NOT remove models unless --remove-models is passed"
    echo "  - Does NOT remove pyenv unless --remove-pyenv is passed"
    exit 0
}

log() {
    echo -e "  ${GREEN}✓${NC} $1"
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"
}

warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    echo "[$(date '+%H:%M:%S')] WARN: $1" >> "$LOG_FILE"
}

err() {
    echo -e "  ${RED}✗${NC} $1"
    echo "[$(date '+%H:%M:%S')] ERROR: $1" >> "$LOG_FILE"
}

info() {
    echo -e "  ${BLUE}→${NC} $1"
}

step() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ▸ $1${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"
}

confirm() {
    if $YES_ALL; then return 0; fi
    if $DRY_RUN; then return 0; fi
    read -p "  $1 [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Safely stop and disable a systemd service (system-level)
remove_system_service() {
    local svc="$1"
    if systemctl is-enabled "$svc" &>/dev/null || systemctl is-active "$svc" &>/dev/null; then
        if $DRY_RUN; then
            info "Would stop and disable system service: $svc"
        else
            sudo systemctl stop "$svc" >> "$LOG_FILE" 2>&1 || true
            sudo systemctl disable "$svc" >> "$LOG_FILE" 2>&1 || true
            log "Stopped and disabled: $svc"
        fi
        REMOVED+=("service:$svc")
    fi
    # Remove unit file if it exists
    local unit="/usr/lib/systemd/system/${svc}.service"
    if [ -f "$unit" ]; then
        if $DRY_RUN; then
            info "Would remove: $unit"
        else
            sudo rm -f "$unit"
            log "Removed unit file: $unit"
        fi
        REMOVED+=("file:$unit")
    fi
}

# Safely stop and disable a systemd user service
remove_user_service() {
    local svc="$1"
    if systemctl --user is-enabled "$svc" &>/dev/null || systemctl --user is-active "$svc" &>/dev/null; then
        if $DRY_RUN; then
            info "Would stop and disable user service: $svc"
        else
            systemctl --user stop "$svc" >> "$LOG_FILE" 2>&1 || true
            systemctl --user disable "$svc" >> "$LOG_FILE" 2>&1 || true
            log "Stopped and disabled user service: $svc"
        fi
        REMOVED+=("user-service:$svc")
    fi
    local unit="$HOME/.config/systemd/user/${svc}.service"
    if [ -f "$unit" ]; then
        if $DRY_RUN; then
            info "Would remove: $unit"
        else
            rm -f "$unit"
            log "Removed user unit file: $unit"
        fi
        REMOVED+=("file:$unit")
    fi
}

# Safely remove a file or directory
remove_path() {
    local path="$1"
    local label="${2:-$path}"
    if [ -e "$path" ]; then
        if $DRY_RUN; then
            info "Would remove: $label ($path)"
        else
            if [ -d "$path" ]; then
                rm -rf "$path"
            else
                sudo rm -f "$path" 2>/dev/null || rm -f "$path"
            fi
            log "Removed: $label"
        fi
        REMOVED+=("path:$label")
    else
        SKIPPED+=("$label (not found)")
    fi
}

# Safely remove a file or directory with sudo
remove_path_sudo() {
    local path="$1"
    local label="${2:-$path}"
    if [ -e "$path" ]; then
        if $DRY_RUN; then
            info "Would remove: $label ($path)"
        else
            sudo rm -rf "$path"
            log "Removed: $label"
        fi
        REMOVED+=("path:$label")
    else
        SKIPPED+=("$label (not found)")
    fi
}

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)        DRY_RUN=true; shift ;;
        --yes-all)        YES_ALL=true; shift ;;
        --keep-data)      KEEP_DATA=true; shift ;;
        --remove-pyenv)   REMOVE_PYENV=true; shift ;;
        --remove-models)  REMOVE_MODELS=true; shift ;;
        -h|--help)        usage ;;
        *)                err "Unknown option: $1"; usage ;;
    esac
done

# ============================================================
echo ""
echo "╔══════════════════════════════════════╗"
echo "║  Halo AI Core v${VERSION} — Uninstall  ║"
echo "║  Designed and built by the architect ║"
echo "╚══════════════════════════════════════╝"
echo ""

if $DRY_RUN; then
    warn "DRY RUN — nothing will be removed"
    echo ""
fi

if $KEEP_DATA; then
    info "KEEP DATA — models and benchmark results will be preserved"
    echo ""
fi

# Pre-flight
if [ "$(id -u)" -eq 0 ]; then
    err "Do not run as root. Run as your user with sudo access."
    exit 1
fi

if ! sudo -n true 2>/dev/null; then
    if $DRY_RUN; then
        warn "sudo not available — dry-run will show planned actions only"
    else
        err "Passwordless sudo required."
        exit 1
    fi
fi

# Confirm
if ! $YES_ALL && ! $DRY_RUN; then
    echo -e "  ${RED}This will remove Halo AI Core from $(cat /proc/sys/kernel/hostname 2>/dev/null || hostname).${NC}"
    echo ""
    if ! confirm "Are you sure you want to continue?"; then
        echo ""
        echo "  \"Shall we play a game?\" — WOPR"
        echo "  How about... not uninstalling. Good choice."
        echo ""
        exit 0
    fi
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Halo AI Core uninstall started" >> "$LOG_FILE"

# ============================================================
# 1. SYSTEM SERVICES
# ============================================================
step "Stopping System Services"

# halo-autoload (system service)
remove_system_service "halo-autoload"

# WireGuard
remove_system_service "wg-quick@wg0"

# Old/stale services that install.sh used to create or clean up
for old_svc in vllm-server lemonade lemonade-ui gaia gaia-ui llama-server kokoro-tts whisper-server; do
    remove_system_service "$old_svc"
done

# Reload systemd after removing system units
if ! $DRY_RUN; then
    sudo systemctl daemon-reload >> "$LOG_FILE" 2>&1 || true
fi

# ============================================================
# 2. USER SERVICES
# ============================================================
step "Stopping User Services"

# halo-stats (user service)
remove_user_service "halo-stats"

# interviewer (user service)
remove_user_service "interviewer"

# Reload user systemd
if ! $DRY_RUN; then
    systemctl --user daemon-reload 2>/dev/null || true
fi

# ============================================================
# 3. CADDY CONFIGS (not Caddy itself — it's a pacman package)
# ============================================================
step "Removing Caddy Configs"

# Remove halo-specific Caddy configs
remove_path_sudo "/etc/caddy/conf.d/halo-services.caddy" "Caddy services config"

# Remove stale caddy configs from old installs
for old_caddy in llm-api.caddy lemonade-ui.caddy gaia-ui.caddy gaia-api.caddy llama.caddy; do
    remove_path_sudo "/etc/caddy/conf.d/${old_caddy}" "Stale Caddy config: $old_caddy"
done

# Check if the main Caddyfile was ours (contains "halo" reference)
if [ -f /etc/caddy/Caddyfile ]; then
    if grep -qi "halo" /etc/caddy/Caddyfile 2>/dev/null; then
        if $DRY_RUN; then
            info "Would remove: /etc/caddy/Caddyfile (halo-ai config)"
        else
            sudo rm -f /etc/caddy/Caddyfile
            log "Removed halo-ai Caddyfile"
            # Restore Caddy to a clean state
            echo "# Caddy — default (halo-ai removed)" | sudo tee /etc/caddy/Caddyfile > /dev/null
        fi
        REMOVED+=("path:/etc/caddy/Caddyfile")
    else
        SKIPPED+=("Caddyfile (not ours, leaving it)")
    fi
fi

# Reload Caddy if it's still running
if ! $DRY_RUN; then
    if systemctl is-active caddy &>/dev/null; then
        sudo systemctl reload caddy >> "$LOG_FILE" 2>&1 || true
        log "Caddy reloaded with clean config"
    fi
fi

# ============================================================
# 4. WIREGUARD CONFIGS
# ============================================================
step "Removing WireGuard Configs"

remove_path_sudo "/etc/wireguard/wg0.conf" "WireGuard server config"
remove_path_sudo "/etc/wireguard/client1.conf" "WireGuard client config"
remove_path_sudo "/etc/wireguard/wg-nat.nft" "WireGuard NAT rules"
remove_path_sudo "/etc/sysctl.d/99-wireguard.conf" "WireGuard sysctl (ip_forward)"

# ============================================================
# 5. DASHBOARD
# ============================================================
step "Removing Dashboard"

remove_path_sudo "/srv/halo-dashboard" "Dashboard files (/srv/halo-dashboard)"
remove_path "$HOME/.local/share/halo-dashboard" "Dashboard stats server"

# ============================================================
# 6. AUTOLOAD SCRIPT
# ============================================================
step "Removing Auto-load Script"

remove_path_sudo "/usr/local/bin/halo-autoload.sh" "Auto-load script"

# ============================================================
# 7. LEMONADE SERVICES (repos, venvs, binaries)
# ============================================================
step "Removing Lemonade Services"

SERVICES_DIR="${HOME}/.local/share/halo-services"
SVCENV="${HOME}/.local/share/halo-services-env"

remove_path "$SERVICES_DIR" "Service repos (interviewer, lemonade-eval, lemonade-nexus)"
remove_path "$SVCENV" "Service Python venv"

# Lemonade Nexus binary
remove_path_sudo "/usr/local/bin/lemonade-nexus" "Lemonade Nexus binary"

# ============================================================
# 8. STATS SERVER
# ============================================================
step "Removing Stats Server"

# Already handled in dashboard section, but make sure
remove_path "$HOME/.local/share/halo-dashboard" "Stats server directory"

# ============================================================
# 9. LEMONADE MODELS (only if --remove-models)
# ============================================================
step "Lemonade Models"

if $REMOVE_MODELS; then
    if $KEEP_DATA; then
        warn "Both --keep-data and --remove-models passed — keeping models (--keep-data wins)"
        SKIPPED+=("Models (--keep-data overrides --remove-models)")
    else
        # Lemonade stores models in ~/.cache/lemonade or ~/.local/share/lemonade
        for model_dir in "$HOME/.cache/lemonade" "$HOME/.local/share/lemonade"; do
            remove_path "$model_dir" "Lemonade model cache: $model_dir"
        done
    fi
else
    info "Models preserved (pass --remove-models to remove)"
    SKIPPED+=("Models (preserved by default)")
fi

# ============================================================
# 10. PYENV (only if --remove-pyenv)
# ============================================================
step "Python / pyenv"

if $REMOVE_PYENV; then
    if confirm "Remove pyenv and all Python versions from ~/.pyenv?"; then
        remove_path "$HOME/.pyenv" "pyenv (~/.pyenv)"
    else
        SKIPPED+=("pyenv (user declined)")
    fi
else
    info "pyenv preserved (pass --remove-pyenv to remove)"
    SKIPPED+=("pyenv (preserved by default)")
fi

# ============================================================
# 11. ROCm ENV FILE (our file, not ROCm itself)
# ============================================================
step "Cleaning ROCm Environment"

if [ -f /etc/profile.d/rocm.sh ]; then
    if grep -qi "halo\|PYTORCH_ROCM_ARCH\|HSA_OVERRIDE" /etc/profile.d/rocm.sh 2>/dev/null; then
        if $DRY_RUN; then
            info "Would remove: /etc/profile.d/rocm.sh (our ROCm env vars)"
        else
            sudo rm -f /etc/profile.d/rocm.sh
            log "Removed ROCm environment file"
        fi
        REMOVED+=("path:/etc/profile.d/rocm.sh")
    else
        SKIPPED+=("rocm.sh (not ours)")
    fi
else
    SKIPPED+=("rocm.sh (not found)")
fi

info "ROCm packages preserved (system-level — remove with pacman if needed)"

# ============================================================
# 12. CPUPOWER CONFIG (our governor setting)
# ============================================================
step "Cleaning CPU Governor Config"

if [ -f /etc/default/cpupower ]; then
    if grep -q "performance" /etc/default/cpupower 2>/dev/null; then
        if $DRY_RUN; then
            info "Would reset: /etc/default/cpupower (governor back to default)"
        else
            echo "governor='schedutil'" | sudo tee /etc/default/cpupower > /dev/null
            log "Reset CPU governor to schedutil"
        fi
        REMOVED+=("config:cpupower governor reset")
    fi
fi

# ============================================================
# 13. CLEANUP — log directory and misc
# ============================================================
step "Cleanup"

# Remove autoload log
remove_path "$HOME/.local/log/halo-autoload.log" "Auto-load log"

# Don't remove the uninstall log — user may want to review it
info "Keeping uninstall log: $LOG_FILE"

# Final systemd reload
if ! $DRY_RUN; then
    sudo systemctl daemon-reload >> "$LOG_FILE" 2>&1 || true
    systemctl --user daemon-reload 2>/dev/null || true
fi

# ============================================================
# SUMMARY
# ============================================================
echo ""
echo "╔══════════════════════════════════════╗"
echo "║   Halo AI Core — Uninstall Summary   ║"
echo "╚══════════════════════════════════════╝"
echo ""

if [ ${#REMOVED[@]} -gt 0 ]; then
    if $DRY_RUN; then
        echo -e "  ${BLUE}Would remove (${#REMOVED[@]} items):${NC}"
    else
        echo -e "  ${GREEN}Removed (${#REMOVED[@]} items):${NC}"
    fi
    for item in "${REMOVED[@]}"; do
        echo -e "    ${GREEN}✓${NC} $item"
    done
    echo ""
fi

if [ ${#SKIPPED[@]} -gt 0 ]; then
    echo -e "  ${YELLOW}Skipped (${#SKIPPED[@]} items):${NC}"
    for item in "${SKIPPED[@]}"; do
        echo -e "    ${YELLOW}⚠${NC} $item"
    done
    echo ""
fi

if [ ${#ERRORS[@]} -gt 0 ]; then
    echo -e "  ${RED}Errors (${#ERRORS[@]}):${NC}"
    for item in "${ERRORS[@]}"; do
        echo -e "    ${RED}✗${NC} $item"
    done
    echo ""
fi

echo -e "  ${BLUE}Not touched:${NC}"
echo -e "    ${BLUE}→${NC} ROCm GPU stack (system packages)"
echo -e "    ${BLUE}→${NC} Caddy web server (pacman package)"
echo -e "    ${BLUE}→${NC} Base packages (git, nodejs, etc.)"
echo -e "    ${BLUE}→${NC} Claude Code (npm global)"
if ! $REMOVE_MODELS; then
    echo -e "    ${BLUE}→${NC} Downloaded models (pass --remove-models)"
fi
if ! $REMOVE_PYENV; then
    echo -e "    ${BLUE}→${NC} pyenv and Python versions (pass --remove-pyenv)"
fi
echo ""

if $DRY_RUN; then
    echo "  \"It's only after we've lost everything that we're free to do anything.\""
    echo "  — Tyler Durden"
    echo ""
    echo "  This was a dry run. Nothing was removed."
    echo "  Run without --dry-run to actually uninstall."
else
    echo "  \"After all, tomorrow is another day.\" — Scarlett O'Hara"
    echo ""
    echo "  Halo AI Core has been removed."
    echo "  Log: $LOG_FILE"
    echo ""
    echo "  To fully clean up, you may also want to:"
    echo "    - Reboot to clear kernel modules and env vars"
    echo "    - Remove Caddy entirely: sudo pacman -R caddy"
    echo "    - Remove ROCm: sudo pacman -R rocm-hip-sdk rocm-opencl-sdk"
    echo "    - Remove WireGuard tools: sudo pacman -R wireguard-tools qrencode nftables"
fi

echo ""
echo "  Designed and built by the architect."
echo ""

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Uninstall complete. Removed: ${#REMOVED[@]}, Skipped: ${#SKIPPED[@]}, Errors: ${#ERRORS[@]}" >> "$LOG_FILE"
