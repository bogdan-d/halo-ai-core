#!/usr/bin/env bash
# Pull latest v0.2.0 artifacts into the airootfs overlay.
# Run before mkarchiso. Idempotent.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO_ROOT="$ROOT/iso/profile/airootfs"
DIST="$ROOT/release/dist"

[[ -d "$DIST" ]] || { echo "run release/build-release.sh first (no release/dist)"; exit 1; }

echo "[stage] extracting v0.2.0 binaries into ISO overlay"
mkdir -p "$ISO_ROOT/usr/local/bin" "$ISO_ROOT/usr/local/lib" "$ISO_ROOT/opt/halo-ai/models"
tar --zstd -xf "$DIST/bitnet_decode-rdna.tar.zst" -C "$ISO_ROOT/usr/local/"
tar --zstd -xf "$DIST/agent_cpp.tar.zst"          -C "$ISO_ROOT/usr/local/"
tar --zstd -xf "$DIST/librocm_cpp-rdna.tar.zst"   -C "$ISO_ROOT/usr/local/"
tar --zstd -xf "$DIST/halo-1bit-2b.tar.zst"       -C "$ISO_ROOT/opt/halo-ai/" # leave top-level models/ dir
# halo-ai-core repo clone as /etc/skel — user's first login gets it
echo "[stage] cloning halo-ai-core into /etc/skel"
rm -rf "$ISO_ROOT/etc/skel/halo-ai-core"
mkdir -p "$ISO_ROOT/etc/skel/halo-ai-core"
git -C "$ROOT" archive --format=tar HEAD | tar -x -C "$ISO_ROOT/etc/skel/halo-ai-core"
# Claude state (tamper-light — memory + rules only; no secrets)
if [[ -f /srv/pxe/http/claude-state.tar.gz ]]; then
    echo "[stage] copying Claude memory state"
    cp /srv/pxe/http/claude-state.tar.gz "$ISO_ROOT/etc/skel/claude-state.tar.gz"
fi
echo "[stage] done. artifacts staged in $ISO_ROOT"
du -sh "$ISO_ROOT/usr/local/bin" "$ISO_ROOT/usr/local/lib" "$ISO_ROOT/opt/halo-ai/models" "$ISO_ROOT/etc/skel" 2>/dev/null
