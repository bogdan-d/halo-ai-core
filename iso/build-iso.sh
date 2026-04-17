#!/usr/bin/env bash
# halo-ai-core iso/build-iso.sh — produce a bootable live ISO with
# halo-ai-core + ROCm + our v0.2.0 binaries pre-staged.
#
# Produces:  out/halo-ai-core-YYYY.MM.DD-x86_64.iso
#            (flash to USB with: sudo dd if=<iso> of=/dev/sdX bs=4M conv=fsync)
#
# Requirements: archiso, sudo, ~20 GB free in /tmp/archiso-work
# Time: ~20 min (most of it pacman fetching rocm-hip-sdk and friends)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE="$ROOT/iso/profile"
WORK="${WORK:-/tmp/archiso-work}"
OUT="$ROOT/iso/out"

command -v mkarchiso >/dev/null || { echo "install archiso: sudo pacman -S archiso"; exit 1; }

echo "[iso] staging v0.2.0 binaries + model into profile/airootfs"
"$ROOT/iso/stage-binaries.sh"

echo "[iso] running mkarchiso (this takes ~20 min)"
sudo rm -rf "$WORK"
mkdir -p "$WORK" "$OUT"
sudo mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"

echo
echo "[iso] done."
ls -lh "$OUT"/*.iso 2>/dev/null | tail
echo
echo "flash to USB:   sudo dd if=<iso> of=/dev/sdX bs=4M conv=fsync status=progress"
echo "boot from USB:  pick it from BIOS boot order; defaults to live shell"
