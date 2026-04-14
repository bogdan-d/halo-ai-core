#!/bin/bash
# ============================================================
# Halo AI Core — USB Builder
# "I carry the fire." — The Road
#
# Builds a bootable USB SSD with the full halo-ai stack.
# Plug into any AMD Strix Halo machine, boot, talk.
#
# Requirements:
#   - USB 3.2 SSD (256GB+, Samsung T7 or similar)
#   - Arch Linux host with pacstrap + arch-install-scripts
#   - Internet connection (downloads ~5GB of packages + models)
#   - Run as your user with sudo access (NOT as root)
#
# Usage:
#   ./build-usb.sh /dev/sdX              # interactive
#   ./build-usb.sh /dev/sdX --yes-all    # non-interactive
#   ./build-usb.sh --dry-run             # show what would happen
#
# Result:
#   Bootable Arch Linux USB with:
#   - Kernel 7.0 mainline
#   - Full halo-ai stack (Lemonade, llama.cpp, Kokoro, Whisper)
#   - Qwen3-Coder-30B model pre-loaded
#   - Voice pipeline ready on boot
#   - Autologin, no desktop needed
#   - Everything on the stick — nothing on the host
#
# Designed and built by the architect.
# ============================================================
set -euo pipefail

VERSION="2.0.0"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

log() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
err() { echo -e "  ${RED}✗${NC} $1"; }
info() { echo -e "  ${BLUE}→${NC} $1"; }

# ── Parse Args ──────────────────────────────────────────────

DEVICE=""
YES_ALL=false
DRY_RUN=false
MODEL_PATH=""
INCLUDE_MODEL=true

usage() {
    echo "Halo AI Core v${VERSION} — USB Builder"
    echo ""
    echo "Usage: ./build-usb.sh /dev/sdX [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run        Show what would happen without doing it"
    echo "  --yes-all        Skip all confirmation prompts"
    echo "  --no-model       Skip copying the LLM model (saves ~18GB)"
    echo "  --model <path>   Use a specific model file (default: auto-detect)"
    echo "  -h, --help       Show this help"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)    DRY_RUN=true; shift ;;
        --yes-all)    YES_ALL=true; shift ;;
        --no-model)   INCLUDE_MODEL=false; shift ;;
        --model)      MODEL_PATH="$2"; shift 2 ;;
        -h|--help)    usage ;;
        /dev/*)       DEVICE="$1"; shift ;;
        *)            err "Unknown option: $1"; usage ;;
    esac
done

# ── Pre-flight ──────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  Halo AI Core v${VERSION} — USB Builder  ║"
echo "║  \"I carry the fire.\" — The Road     ║"
echo "╚══════════════════════════════════════╝"
echo ""

if $DRY_RUN; then
    warn "DRY RUN — nothing will be written"
    echo ""
fi

if [ "$(id -u)" -eq 0 ]; then
    err "Do not run as root. Run as your user with sudo access."
    exit 1
fi

# Install required tools
REQUIRED_PKGS="arch-install-scripts dosfstools btrfs-progs"
for pkg in $REQUIRED_PKGS; do
    if ! pacman -Q "$pkg" &>/dev/null; then
        info "Installing $pkg..."
        sudo pacman -S --needed --noconfirm "$pkg" 2>/dev/null
    fi
done

# ── Device Selection ────────────────────────────────────────

if [ -z "$DEVICE" ]; then
    echo "  Available USB devices:"
    echo ""
    lsblk -d -o NAME,SIZE,MODEL,TRAN | grep -E "usb|NAME" | while read -r line; do
        echo "    $line"
    done
    echo ""
    read -p "  Enter device (e.g., /dev/sdb): " DEVICE
fi

if [ ! -b "$DEVICE" ]; then
    err "Device $DEVICE not found"
    exit 1
fi

# Safety check — make sure it's USB
TRAN=$(lsblk -d -n -o TRAN "$DEVICE" 2>/dev/null || echo "unknown")
if [[ "$TRAN" != "usb" ]]; then
    err "Device $DEVICE is not a USB device (transport: $TRAN)"
    err "This script only writes to USB devices for safety."
    exit 1
fi

DEV_SIZE=$(lsblk -d -n -o SIZE "$DEVICE")
DEV_MODEL=$(lsblk -d -n -o MODEL "$DEVICE" | xargs)

echo ""
echo -e "  ${BOLD}Target: $DEVICE${NC}"
echo "  Size:  $DEV_SIZE"
echo "  Model: $DEV_MODEL"
echo ""

if ! $YES_ALL && ! $DRY_RUN; then
    echo -e "  ${RED}WARNING: This will ERASE ALL DATA on $DEVICE${NC}"
    read -p "  Type YES to continue: " CONFIRM
    [[ "$CONFIRM" == "YES" ]] || { echo "Aborted."; exit 0; }
fi

# ── Find Model ──────────────────────────────────────────────

if $INCLUDE_MODEL && [ -z "$MODEL_PATH" ]; then
    # Auto-detect best model
    for candidate in \
        "$HOME/models/Qwen3-Coder-30B-A3B-Q4_K_M.gguf" \
        "$HOME/models/Qwen3.5-35B-A3B-Q4_K_XL.gguf" \
        "$HOME/models/Qwen3-Coder-Next-UD-TQ1_0.gguf"; do
        if [ -f "$candidate" ]; then
            MODEL_PATH="$candidate"
            break
        fi
    done
    if [ -z "$MODEL_PATH" ]; then
        warn "No model found — USB will boot but need a model downloaded after"
        INCLUDE_MODEL=false
    else
        MODEL_SIZE=$(du -h "$MODEL_PATH" | cut -f1)
        log "Model: $(basename "$MODEL_PATH") ($MODEL_SIZE)"
    fi
fi

if $DRY_RUN; then
    echo ""
    info "Would partition $DEVICE:"
    info "  Part 1: 512MB EFI (FAT32)"
    info "  Part 2: Remaining (btrfs, root)"
    info "Would pacstrap Arch Linux base system"
    info "Would run install.sh inside chroot"
    if $INCLUDE_MODEL; then
        info "Would copy model: $(basename "${MODEL_PATH:-none}")"
    fi
    info "Would configure autologin + voice autostart"
    echo ""
    echo "  Dry run complete. Nothing was written."
    exit 0
fi

# ── Build ───────────────────────────────────────────────────

MNT="/tmp/halo-usb-build"

echo ""
info "Building USB — this takes 10-20 minutes depending on internet speed"
echo ""

# Step 1: Partition
info "Partitioning $DEVICE..."
sudo wipefs -a "$DEVICE"
sudo parted -s "$DEVICE" \
    mklabel gpt \
    mkpart ESP fat32 1MiB 513MiB \
    set 1 esp on \
    mkpart root btrfs 513MiB 100%

# Wait for kernel to see partitions
sleep 2
sudo partprobe "$DEVICE"
sleep 1

PART_EFI="${DEVICE}1"
PART_ROOT="${DEVICE}2"

# Handle nvme-style partition names (p1 instead of 1)
if [ ! -b "$PART_EFI" ]; then
    PART_EFI="${DEVICE}p1"
    PART_ROOT="${DEVICE}p2"
fi

# Step 2: Format
info "Formatting..."
sudo mkfs.fat -F32 "$PART_EFI"
sudo mkfs.btrfs -f -L halo-usb "$PART_ROOT"

# Step 3: Mount
sudo mkdir -p "$MNT"
sudo mount "$PART_ROOT" "$MNT"
sudo mkdir -p "$MNT/boot"
sudo mount "$PART_EFI" "$MNT/boot"

log "Partitioned and mounted"

# Step 4: Pacstrap base system
info "Installing base system (this takes a few minutes)..."
sudo pacstrap -K "$MNT" \
    base linux linux-firmware \
    base-devel git openssh networkmanager curl wget htop nano nodejs npm \
    vulkan-tools btrfs-progs cpupower \
    sudo zsh grub efibootmgr \
    python python-pip uv

log "Base system installed"

# Step 5: Generate fstab
sudo genfstab -U "$MNT" | sudo tee "$MNT/etc/fstab" > /dev/null
log "fstab generated"

# Step 6: Configure system in chroot
info "Configuring system..."
sudo arch-chroot "$MNT" /bin/bash << 'CHROOT'
# Timezone + locale
ln -sf /usr/share/zoneinfo/America/Moncton /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "halo-usb" > /etc/hostname
cat > /etc/hosts << HOSTS
127.0.0.1 localhost
::1       localhost
127.0.1.1 halo-usb.localdomain halo-usb
HOSTS

# User — bcloud with passwordless sudo
useradd -m -G wheel,video,render -s /bin/zsh bcloud 2>/dev/null || true
echo "bcloud:haloai" | chpasswd
echo "bcloud ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/bcloud

# Autologin on tty1
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << AUTOLOGIN
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin bcloud --noclear %I linux
AUTOLOGIN

# Enable services
systemctl enable NetworkManager
systemctl enable sshd

# Bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=halo-usb --removable
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=2/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet iommu=pt"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
CHROOT

log "System configured"

# Step 7: Copy halo-ai-core repo
info "Copying halo-ai-core to USB..."
sudo cp -r "$SCRIPT_DIR" "$MNT/home/bcloud/halo-ai-core"
sudo chown -R 1000:1000 "$MNT/home/bcloud/halo-ai-core"
log "halo-ai-core copied"

# Step 8: Create first-boot script (runs install.sh on first boot)
sudo tee "$MNT/home/bcloud/first-boot.sh" > /dev/null << 'FIRSTBOOT'
#!/bin/bash
# halo-ai USB — first boot setup
# "Welcome to the real world." — Morpheus

if [ -f "$HOME/.halo-installed" ]; then
    echo "halo-ai already installed. Delete ~/.halo-installed to re-run."
    exit 0
fi

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  halo-ai USB — First Boot Setup     ║"
echo "║  \"Welcome to the real world.\"       ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "This will install the full halo-ai stack."
echo "Internet connection required."
echo ""

cd "$HOME/halo-ai-core"
bash install.sh --yes-all

touch "$HOME/.halo-installed"
echo ""
echo "Done. Reboot to start all services."
echo "  sudo reboot"
FIRSTBOOT
sudo chmod +x "$MNT/home/bcloud/first-boot.sh"
sudo chown 1000:1000 "$MNT/home/bcloud/first-boot.sh"

# Add first-boot to .zprofile so it runs on first login
sudo tee -a "$MNT/home/bcloud/.zprofile" > /dev/null << 'ZPROF'
# halo-ai first boot
if [ ! -f "$HOME/.halo-installed" ]; then
    bash "$HOME/first-boot.sh"
fi
ZPROF
sudo chown 1000:1000 "$MNT/home/bcloud/.zprofile"

log "First-boot script installed"

# Step 9: Copy model (if available)
if $INCLUDE_MODEL && [ -f "$MODEL_PATH" ]; then
    info "Copying model: $(basename "$MODEL_PATH") — this takes a few minutes..."
    sudo mkdir -p "$MNT/home/bcloud/models"
    sudo cp "$MODEL_PATH" "$MNT/home/bcloud/models/"
    sudo chown -R 1000:1000 "$MNT/home/bcloud/models"
    log "Model copied: $(basename "$MODEL_PATH")"
fi

# Step 10: Cleanup
info "Syncing and unmounting..."
sync
sudo umount -R "$MNT"
sudo rmdir "$MNT" 2>/dev/null || true

# ── Done ────────────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  USB Build Complete                  ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "  Device:  $DEVICE ($DEV_SIZE)"
echo "  Model:   $DEV_MODEL"
echo "  System:  Arch Linux, kernel 7.0 mainline"
echo "  Stack:   halo-ai-core v${VERSION}"
if $INCLUDE_MODEL; then
echo "  LLM:     $(basename "$MODEL_PATH")"
fi
echo ""
echo "  ── HOW TO USE ──────────────────────────"
echo ""
echo "  1. Plug the USB into any AMD Strix Halo machine"
echo "  2. Boot from USB (F12/F2/DEL at BIOS)"
echo "  3. It auto-logs in as bcloud"
echo "  4. First boot runs install.sh automatically"
echo "  5. Reboot after install completes"
echo "  6. Open http://localhost:13305 and start talking"
echo ""
echo "  Password: haloai (change it: passwd)"
echo ""
echo "  \"I carry the fire.\""
echo ""
echo "  Designed and built by the architect."
echo ""
