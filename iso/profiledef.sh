#!/usr/bin/env bash
# shellcheck disable=SC2034
# ============================================================
# Halo AI Core — Custom Arch ISO Profile
# "You take the red pill, you stay in Wonderland, and I show
#  you how deep the rabbit hole goes." — Morpheus, The Matrix
#
# Build: sudo mkarchiso -v -w /tmp/halo-iso-work -o ~/iso-output iso/
# ============================================================

iso_name="halo-ai-core"
iso_label="HALO_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="The Architect <https://github.com/stampby/halo-ai-core>"
iso_application="Halo AI Core — AMD Strix Halo AI Platform"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=(
    'bios.syslinux.mbr'
    'bios.syslinux.eltorito'
    'uefi-x64.systemd-boot.esp'
    'uefi-x64.systemd-boot.eltorito'
)
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')

# File permissions: [path]="uid:gid:mode"
file_permissions=(
    ["/etc/shadow"]="0:0:400"
    ["/root"]="0:0:750"
    ["/root/.automated_script.sh"]="0:0:755"
    ["/usr/local/bin/halo-install"]="0:0:755"
    ["/opt/halo-autoinstall/autoinstall.sh"]="0:0:755"
)
