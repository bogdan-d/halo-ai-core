#!/usr/bin/env bash
# halo-ai-core install.sh — auto-dispatcher.
#
# Detects GPU arch. Strix Halo (gfx1151) users → fast path, pre-built binaries.
# Everyone else → source build (4 hours, produces arch-specific kernels).
#
# You can force a path with:
#   ./install.sh --strixhalo     force fast path
#   ./install.sh --source        force source build
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATH_CHOICE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --strixhalo) PATH_CHOICE="strixhalo"; shift ;;
        --source)    PATH_CHOICE="source";    shift ;;
        --help|-h)
            cat <<EOF
Usage: ./install.sh [--strixhalo|--source] [options...]

  --strixhalo    force fast path (pre-built binaries for gfx1151)
  --source       force source build (any GPU arch, ~4 hours)

All other options pass through to the chosen installer. See:
  ./install-strixhalo.sh --help
  ./install-source.sh    --help
EOF
            exit 0 ;;
        *) break ;;   # remainder passes through
    esac
done

if [[ -z "$PATH_CHOICE" ]]; then
    if command -v rocminfo &>/dev/null; then
        ARCH=$(rocminfo 2>/dev/null | grep -oP 'gfx\d+' | head -1 || true)
    else
        ARCH=""
    fi
    if [[ "$ARCH" == "gfx1151" ]]; then
        PATH_CHOICE="strixhalo"
    else
        PATH_CHOICE="source"
    fi
fi

case "$PATH_CHOICE" in
    strixhalo) exec "$ROOT_DIR/install-strixhalo.sh" "$@" ;;
    source)    exec "$ROOT_DIR/install-source.sh"    "$@" ;;
    *)         echo "unknown path: $PATH_CHOICE"; exit 1 ;;
esac
