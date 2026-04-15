#!/bin/bash
# ============================================================
# Halo AI Core — Automated Installer
# "Fate, it seems, is not without a sense of irony."
#   — Morpheus, The Matrix
#
# This script runs from the live ISO environment.
# It calls archinstall for base OS, then deploys halo-ai-core.
#
# Boot menu options:
#   1) Auto Install  — runs this script (full unattended)
#   2) Live USB      — drops to shell with halo tools available
#   3) Manual Install — standard archinstall TUI
# ============================================================
set -euo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Config ---
HALO_REPO="https://github.com/stampby/halo-ai-core.git"
HALO_USER="bcloud"
CONFIG_DIR="/opt/halo-autoinstall"
LOG="/tmp/halo-autoinstall.log"
INSTALL_TARGET="/mnt"

# Disk detection — find the largest NVMe or SATA drive
detect_disk() {
    local disk=""
    # Prefer NVMe
    disk=$(lsblk -dno NAME,SIZE,TYPE | grep 'disk' | grep 'nvme' | sort -k2 -h | tail -1 | awk '{print $1}')
    # Fall back to SATA/USB
    if [[ -z "$disk" ]]; then
        disk=$(lsblk -dno NAME,SIZE,TYPE | grep 'disk' | grep -v 'loop\|sr\|rom' | sort -k2 -h | tail -1 | awk '{print $1}')
    fi
    echo "/dev/$disk"
}

banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << 'BANNER'

    ██╗  ██╗ █████╗ ██╗      ██████╗
    ██║  ██║██╔══██╗██║     ██╔═══██╗
    ███████║███████║██║     ██║   ██║
    ██╔══██║██╔══██║██║     ██║   ██║
    ██║  ██║██║  ██║███████╗╚██████╔╝
    ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝
       A I   C O R E   I N S T A L L E R

BANNER
    echo -e "${NC}"
    echo -e "${BLUE}  AMD Strix Halo AI Platform — Fully Automated${NC}"
    echo -e "${BLUE}  \"There is no spoon.\" — The Matrix${NC}"
    echo ""
}

info()  { echo -e "${GREEN}[INFO]${NC}  $*" | tee -a "$LOG"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*" | tee -a "$LOG"; }
error() { echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG"; }
step()  { echo -e "\n${CYAN}${BOLD}>>> $*${NC}" | tee -a "$LOG"; }

# ============================================================
# Pre-flight checks
# ============================================================
preflight() {
    step "Pre-flight checks"

    # Must be root
    if [[ $EUID -ne 0 ]]; then
        error "Must run as root"
        exit 1
    fi

    # Check UEFI
    if [[ -d /sys/firmware/efi ]]; then
        info "UEFI mode detected"
    else
        warn "BIOS mode — UEFI recommended for Strix Halo"
    fi

    # Detect hardware
    local cpu
    cpu=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
    info "CPU: $cpu"

    local mem_gb
    mem_gb=$(awk '/MemTotal/ {printf "%.0f", $2/1024/1024}' /proc/meminfo)
    info "RAM: ${mem_gb} GB"

    # GPU detection
    if lspci | grep -qi 'radeon\|amd.*display\|gfx'; then
        info "AMD GPU detected"
        local gpu_name
        gpu_name=$(lspci | grep -i 'vga\|display' | grep -i 'amd\|radeon' | head -1 | sed 's/.*: //')
        info "GPU: $gpu_name"
    fi

    # NPU detection
    if lspci | grep -qi 'signal processing.*amd\|xdna\|1502:00'; then
        info "AMD NPU (XDNA2) detected"
    fi

    # Network
    if ping -c1 -W3 archlinux.org &>/dev/null; then
        info "Network: connected"
    else
        warn "Network: no connection — attempting DHCP..."
        dhcpcd &>/dev/null || true
        sleep 3
        if ping -c1 -W3 archlinux.org &>/dev/null; then
            info "Network: connected via DHCP"
        else
            error "No network — cannot proceed"
            error "Connect ethernet or configure WiFi manually, then re-run"
            exit 1
        fi
    fi
}

# ============================================================
# Disk selection (interactive if multiple disks)
# ============================================================
select_disk() {
    step "Disk detection"

    local disks
    disks=$(lsblk -dno NAME,SIZE,TYPE,MODEL | grep 'disk' | grep -v 'loop\|sr\|rom')
    local count
    count=$(echo "$disks" | wc -l)

    if [[ $count -eq 0 ]]; then
        error "No disks found"
        exit 1
    elif [[ $count -eq 1 ]]; then
        TARGET_DISK=$(detect_disk)
        local size model
        size=$(lsblk -dno SIZE "$TARGET_DISK" | xargs)
        model=$(lsblk -dno MODEL "$TARGET_DISK" | xargs)
        info "Single disk detected: $TARGET_DISK ($size, $model)"
    else
        info "Multiple disks detected:"
        echo ""
        local i=1
        while IFS= read -r line; do
            echo -e "  ${CYAN}[$i]${NC} /dev/$line"
            i=$((i+1))
        done <<< "$disks"
        echo ""

        # Auto-select largest NVMe if unattended
        if [[ "${HALO_UNATTENDED:-false}" == "true" ]]; then
            TARGET_DISK=$(detect_disk)
            info "Auto-selected: $TARGET_DISK (largest NVMe)"
        else
            echo -en "${YELLOW}Select disk [1-$count]: ${NC}"
            read -r choice
            local dev_name
            dev_name=$(echo "$disks" | sed -n "${choice}p" | awk '{print $1}')
            TARGET_DISK="/dev/$dev_name"
        fi
    fi

    # Update archinstall config with selected disk
    local config="${CONFIG_DIR}/user_configuration.json"
    if [[ -f "$config" ]]; then
        # Replace the null device with actual device path
        sed -i "s|\"device\": null|\"device\": \"${TARGET_DISK}\"|g" "$config"
        info "Target disk: $TARGET_DISK"
    fi
}

# ============================================================
# Dangerous confirmation
# ============================================================
confirm_wipe() {
    if [[ "${HALO_UNATTENDED:-false}" == "true" ]]; then
        info "Unattended mode — skipping confirmation"
        return 0
    fi

    echo ""
    echo -e "${RED}${BOLD}  ╔══════════════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD}  ║  WARNING: THIS WILL DESTROY ALL DATA ON     ║${NC}"
    echo -e "${RED}${BOLD}  ║  ${TARGET_DISK}$(printf '%*s' $((33 - ${#TARGET_DISK})) '')║${NC}"
    echo -e "${RED}${BOLD}  ║                                              ║${NC}"
    echo -e "${RED}${BOLD}  ║  There is no undo. \"Welcome to the desert    ║${NC}"
    echo -e "${RED}${BOLD}  ║  of the real.\" — Morpheus                    ║${NC}"
    echo -e "${RED}${BOLD}  ╚══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -en "${YELLOW}Type 'YES' to continue, anything else to abort: ${NC}"
    read -r confirm
    if [[ "$confirm" != "YES" ]]; then
        info "Aborted by user"
        exit 0
    fi
}

# ============================================================
# Set passwords interactively (unless unattended)
# ============================================================
set_credentials() {
    step "User credentials"

    local creds="${CONFIG_DIR}/user_credentials.json"

    if [[ "${HALO_UNATTENDED:-false}" == "true" ]]; then
        # Unattended: use default password (user MUST change on first login)
        info "Unattended mode — default credentials (change on first login!)"
        cat > "$creds" << 'CREDS'
{
    "!root-password": "halo-temp-changeme",
    "!users": [
        {
            "!password": "halo-temp-changeme",
            "sudo": true,
            "username": "bcloud"
        }
    ]
}
CREDS
        return
    fi

    echo -en "${CYAN}Username [bcloud]: ${NC}"
    read -r username
    username="${username:-bcloud}"

    echo -en "${CYAN}Password: ${NC}"
    read -rs password1
    echo ""
    echo -en "${CYAN}Confirm:  ${NC}"
    read -rs password2
    echo ""

    if [[ "$password1" != "$password2" ]]; then
        error "Passwords don't match"
        exit 1
    fi

    if [[ -z "$password1" ]]; then
        error "Password cannot be empty"
        exit 1
    fi

    cat > "$creds" << CREDS
{
    "!root-password": "${password1}",
    "!users": [
        {
            "!password": "${password1}",
            "sudo": true,
            "username": "${username}"
        }
    ]
}
CREDS

    # Update username in main config's custom_commands if needed
    HALO_USER="$username"
    info "User: $username (with sudo)"
}

# ============================================================
# Kernel selection
# ============================================================
select_kernel() {
    step "Kernel selection"

    if [[ "${HALO_UNATTENDED:-false}" == "true" ]]; then
        KERNEL="linux"
        info "Unattended mode — using stock kernel"
        return
    fi

    echo ""
    echo -e "  ${CYAN}[1]${NC} linux          — Stock Arch kernel (safe, reliable)"
    echo -e "  ${CYAN}[2]${NC} linux-zen      — Zen kernel (optimized desktop/gaming)"
    echo -e "  ${CYAN}[3]${NC} linux-lts      — LTS kernel (ultra stable)"
    echo ""
    echo -e "  ${YELLOW}Note: CachyOS kernel can be installed later via install.sh${NC}"
    echo -e "  ${YELLOW}      Kernel 7.0+ required for NPU support${NC}"
    echo ""
    echo -en "${YELLOW}Select kernel [1]: ${NC}"
    read -r choice

    case "${choice:-1}" in
        1) KERNEL="linux" ;;
        2) KERNEL="linux-zen" ;;
        3) KERNEL="linux-lts" ;;
        *) KERNEL="linux" ;;
    esac

    # Update archinstall config
    local config="${CONFIG_DIR}/user_configuration.json"
    sed -i "s|\"kernels\": \[\"linux\"\]|\"kernels\": [\"${KERNEL}\"]|g" "$config"
    info "Kernel: $KERNEL"
}

# ============================================================
# Run archinstall
# ============================================================
run_archinstall() {
    step "Running archinstall (base OS installation)"
    info "This may take 5-15 minutes depending on your connection..."

    archinstall \
        --config "${CONFIG_DIR}/user_configuration.json" \
        --creds "${CONFIG_DIR}/user_credentials.json" \
        --silent \
        2>&1 | tee -a "$LOG"

    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        error "archinstall failed — check $LOG"
        exit 1
    fi

    info "Base OS installed successfully"
}

# ============================================================
# Post-install: deploy halo-ai-core into the new system
# ============================================================
post_install() {
    step "Deploying Halo AI Core into new system"

    # archinstall mounts the new system at /mnt
    local target="/mnt"

    if [[ ! -d "$target/etc" ]]; then
        error "Target system not mounted at $target"
        exit 1
    fi

    # Clone halo-ai-core into the new system
    info "Cloning halo-ai-core..."
    arch-chroot "$target" /bin/bash -c "
        su - ${HALO_USER} -c 'git clone ${HALO_REPO} /home/${HALO_USER}/halo-ai-core' || true
    " >> "$LOG" 2>&1

    # Create first-boot service that runs install.sh
    info "Creating first-boot installer service..."
    cat > "$target/etc/systemd/system/halo-first-boot.service" << EOF
[Unit]
Description=Halo AI Core — First Boot Installer
After=network-online.target
Wants=network-online.target
ConditionPathExists=/home/${HALO_USER}/halo-ai-core/install.sh

[Service]
Type=oneshot
User=${HALO_USER}
WorkingDirectory=/home/${HALO_USER}/halo-ai-core
ExecStart=/bin/bash -c '/home/${HALO_USER}/halo-ai-core/install.sh --yes-all 2>&1 | tee /home/${HALO_USER}/.local/log/halo-first-boot.log'
ExecStartPost=/bin/systemctl disable halo-first-boot.service
ExecStartPost=/bin/rm -f /root/.halo-pending
StandardOutput=journal+console
StandardError=journal+console
TimeoutStartSec=1800

[Install]
WantedBy=multi-user.target
EOF

    # Enable first-boot service
    arch-chroot "$target" systemctl enable halo-first-boot.service >> "$LOG" 2>&1

    # Set kernel parameters for AMD GPU
    info "Configuring bootloader for Strix Halo..."
    local loader_entry
    loader_entry=$(find "$target/boot/loader/entries/" -name '*.conf' | head -1)
    if [[ -n "$loader_entry" ]]; then
        # Append AMD-specific kernel params
        sed -i '/^options/ s/$/ iommu=pt amd_pstate=active/' "$loader_entry"
        info "Added iommu=pt and amd_pstate=active to boot params"
    fi

    # Pre-create log directory
    arch-chroot "$target" /bin/bash -c "
        mkdir -p /home/${HALO_USER}/.local/log
        chown -R ${HALO_USER}:${HALO_USER} /home/${HALO_USER}/.local
    " >> "$LOG" 2>&1

    # Copy install log to new system
    cp "$LOG" "$target/home/${HALO_USER}/.local/log/halo-autoinstall.log" 2>/dev/null || true

    info "Halo AI Core staged for first-boot deployment"
}

# ============================================================
# Main
# ============================================================
main() {
    banner

    # Parse args
    for arg in "$@"; do
        case "$arg" in
            --unattended) export HALO_UNATTENDED=true ;;
            --help|-h)
                echo "Usage: autoinstall.sh [--unattended]"
                echo ""
                echo "  --unattended   Skip all prompts (auto-select largest NVMe, stock kernel)"
                exit 0
                ;;
        esac
    done

    preflight
    select_disk
    confirm_wipe
    set_credentials
    select_kernel
    run_archinstall
    post_install

    step "Installation complete"
    echo ""
    echo -e "${GREEN}${BOLD}  ╔══════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}  ║  Halo AI Core — Installation Complete       ║${NC}"
    echo -e "${GREEN}${BOLD}  ║                                              ║${NC}"
    echo -e "${GREEN}${BOLD}  ║  On first boot, halo-ai-core install.sh     ║${NC}"
    echo -e "${GREEN}${BOLD}  ║  will deploy all AI services automatically. ║${NC}"
    echo -e "${GREEN}${BOLD}  ║                                              ║${NC}"
    echo -e "${GREEN}${BOLD}  ║  \"I'm going to show them a world where      ║${NC}"
    echo -e "${GREEN}${BOLD}  ║   anything is possible.\" — Neo              ║${NC}"
    echo -e "${GREEN}${BOLD}  ╚══════════════════════════════════════════════╝${NC}"
    echo ""

    if [[ "${HALO_UNATTENDED:-false}" == "true" ]]; then
        info "Rebooting in 10 seconds..."
        sleep 10
        reboot
    else
        echo -en "${YELLOW}Remove the USB drive, then press Enter to reboot...${NC}"
        read -r
        reboot
    fi
}

main "$@"
