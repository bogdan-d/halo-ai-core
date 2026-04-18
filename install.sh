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

# ── CachyOS prerequisite check ──────────────────────────────
# NPU (XDNA2) specialists require the CachyOS kernel patches. Stock Arch and
# other distros silently fall back to CPU/iGPU. Warn loud, don't block —
# advanced users on a custom kernel with amdxdna backported can override with
# HALO_SKIP_OS_CHECK=1.
if [[ "${HALO_SKIP_OS_CHECK:-0}" != "1" ]]; then
    OS_ID=""
    if [[ -r /etc/os-release ]]; then
        OS_ID=$(. /etc/os-release && echo "${ID:-}")
    fi
    if [[ "$OS_ID" != "cachyos" ]]; then
        echo
        echo "  ⚠️  halo-ai-core expects CachyOS (detected: ${OS_ID:-unknown})"
        echo "     The XDNA2 NPU path (echo_ear, lemond-FLM) will not work on"
        echo "     stock Arch / Fedora / Ubuntu — the amdxdna patches are not"
        echo "     in those kernels. The GPU path still works, NPU specialists"
        echo "     will not."
        echo
        echo "     Install CachyOS first: https://cachyos.org/"
        echo "     Or override with HALO_SKIP_OS_CHECK=1 ./install.sh"
        echo
        read -rp "  continue anyway? (y/N): " cont
        [[ "$cont" =~ ^[Yy]$ ]] || exit 1
    fi
fi

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
