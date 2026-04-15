#!/bin/bash
# ============================================================
# Halo AI Core — ISO Builder
# "You've been living in a dream world, Neo." — Morpheus
#
# Builds a custom Arch Linux ISO with halo-ai-core baked in.
# Requires: archiso package (sudo pacman -S archiso)
#
# Usage:
#   sudo ./iso/build-iso.sh              # Build ISO
#   sudo ./iso/build-iso.sh --clean      # Clean work dir + build
#   sudo ./iso/build-iso.sh --usb /dev/sdX  # Build + write to USB
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE_DIR="$SCRIPT_DIR"
WORK_DIR="/tmp/halo-iso-work"
OUT_DIR="${SCRIPT_DIR}/../output"
USB_DEV=""
CLEAN=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${GREEN}[BUILD]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

usage() {
    echo "Halo AI Core — ISO Builder"
    echo ""
    echo "Usage: sudo $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --clean          Remove work directory before building"
    echo "  --usb /dev/sdX   Write ISO to USB drive after building"
    echo "  --work-dir PATH  Override work directory (default: /tmp/halo-iso-work)"
    echo "  --out-dir PATH   Override output directory (default: ../output)"
    echo "  -h, --help       Show this help"
    echo ""
    echo "Prerequisites:"
    echo "  sudo pacman -S archiso"
    exit 0
}

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --clean) CLEAN=true; shift ;;
        --usb)
            USB_DEV="$2"
            shift 2
            ;;
        --work-dir)
            WORK_DIR="$2"
            shift 2
            ;;
        --out-dir)
            OUT_DIR="$2"
            shift 2
            ;;
        -h|--help) usage ;;
        *) error "Unknown option: $1" ;;
    esac
done

# Must be root
if [[ $EUID -ne 0 ]]; then
    error "Must run as root (sudo)"
fi

# Check archiso
if ! command -v mkarchiso &>/dev/null; then
    error "archiso not installed. Run: sudo pacman -S archiso"
fi

# Validate profile
if [[ ! -f "$PROFILE_DIR/profiledef.sh" ]]; then
    error "profiledef.sh not found in $PROFILE_DIR"
fi

echo -e "${CYAN}${BOLD}"
cat << 'BANNER'
    ╔══════════════════════════════════════════╗
    ║  Halo AI Core — ISO Builder              ║
    ║  "Guns. Lots of guns." — Neo             ║
    ╚══════════════════════════════════════════╝
BANNER
echo -e "${NC}"

# Clean work dir if requested
if $CLEAN && [[ -d "$WORK_DIR" ]]; then
    info "Cleaning work directory: $WORK_DIR"
    rm -rf "$WORK_DIR"
fi

# Create output dir
mkdir -p "$OUT_DIR"

# Build
info "Profile:   $PROFILE_DIR"
info "Work dir:  $WORK_DIR"
info "Output:    $OUT_DIR"
echo ""

info "Building ISO... this may take 10-30 minutes"
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$PROFILE_DIR"

# Find the built ISO
ISO_FILE=$(find "$OUT_DIR" -name 'halo-ai-core-*.iso' -type f -printf '%T@ %p\n' | sort -n | tail -1 | awk '{print $2}')

if [[ -z "$ISO_FILE" ]]; then
    error "ISO build failed — no output file found"
fi

ISO_SIZE=$(du -h "$ISO_FILE" | awk '{print $1}')
info "ISO built successfully: $ISO_FILE ($ISO_SIZE)"

# Generate SHA256
sha256sum "$ISO_FILE" > "${ISO_FILE}.sha256"
info "SHA256: $(cat "${ISO_FILE}.sha256")"

# Write to USB if requested
if [[ -n "$USB_DEV" ]]; then
    if [[ ! -b "$USB_DEV" ]]; then
        error "$USB_DEV is not a block device"
    fi

    # Safety check — don't write to mounted devices
    if mount | grep -q "^${USB_DEV}"; then
        error "$USB_DEV is mounted. Unmount first."
    fi

    # Show device info
    local usb_info
    usb_info=$(lsblk -no SIZE,MODEL "$USB_DEV" 2>/dev/null | head -1)
    warn "Writing to $USB_DEV ($usb_info) — ALL DATA WILL BE DESTROYED"
    echo -en "${YELLOW}Type 'YES' to continue: ${NC}"
    read -r confirm
    if [[ "$confirm" != "YES" ]]; then
        info "USB write cancelled"
        exit 0
    fi

    info "Writing ISO to $USB_DEV..."
    dd bs=4M if="$ISO_FILE" of="$USB_DEV" status=progress oflag=sync conv=fsync
    sync

    info "USB drive ready. Remove and boot from it."
fi

echo ""
echo -e "${GREEN}${BOLD}Build complete.${NC}"
echo ""
echo "  ISO:  $ISO_FILE"
echo "  Size: $ISO_SIZE"
echo ""
echo "  Write to USB:"
echo "    sudo dd bs=4M if=$ISO_FILE of=/dev/sdX status=progress oflag=sync"
echo ""
echo "  Test with QEMU:"
echo "    qemu-system-x86_64 -enable-kvm -m 4G -cdrom $ISO_FILE -boot d"
echo ""
