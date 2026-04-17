#!/usr/bin/env bash
# halo-ai-core install-strixhalo.sh — fast path for gfx1151 Strix Halo.
# "If it ain't broke, don't fix it. If it is broke, we've got a tarball for that." — architect
#
# What this script does:
#   1. Verifies GPU is gfx1151 (bail otherwise — see install-source.sh).
#   2. Installs ROCm userspace (rocm-hip-sdk via pacman).
#   3. Downloads pre-built binaries from GitHub Releases (or a local mirror).
#   4. Verifies SHA256SUMS (and GPG sig if present).
#   5. Installs to /usr/local/ and wires systemd.
#
# Time: ~5 minutes. For non-Strix-Halo users, use ./install-source.sh (~4 hours).
set -euo pipefail

# ── Configuration ───────────────────────────────────────────
REPO="${REPO:-stampby/halo-ai-core}"
RELEASE_TAG="${RELEASE_TAG:-latest}"
SOURCE="${SOURCE:-https://github.com/${REPO}/releases/${RELEASE_TAG}/download}"
INSTALL_PREFIX="${INSTALL_PREFIX:-/usr/local}"
MODELS_DIR="${MODELS_DIR:-$HOME/halo-ai/models}"
SKIP_GPG="${SKIP_GPG:-0}"
DRY_RUN=0

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; NC='\033[0m'
log()  { echo -e "${CYAN}[halo-ai]${NC} $1"; }
ok()   { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }
die()  { err "$1"; exit 1; }

# ── Parse args ──────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case $1 in
        --from-local) SOURCE="$2"; shift 2 ;;
        --tag)        RELEASE_TAG="$2"; SOURCE="https://github.com/${REPO}/releases/download/${RELEASE_TAG}"; shift 2 ;;
        --dry-run)    DRY_RUN=1; shift ;;
        --skip-gpg)   SKIP_GPG=1; shift ;;
        --help|-h)
            cat <<EOF
Usage: ./install-strixhalo.sh [options]

Options:
  --from-local <url>   pull artifacts from a LAN mirror instead of GitHub
                       (e.g. http://strixhalo.lan:8000/releases)
  --tag <version>      install a specific release tag (default: latest)
  --dry-run            show what would happen, no changes
  --skip-gpg           skip GPG signature check (SHA256 still enforced)
  --help               this screen
EOF
            exit 0 ;;
        *) die "unknown arg: $1" ;;
    esac
done

# ── Banner ──────────────────────────────────────────────────
echo
echo -e "${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  halo-ai-core — strix halo fast install                  ║${NC}"
echo -e "${BOLD}║  pre-built binaries · gfx1151 wave32 · ~5 min            ║${NC}"
echo -e "${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
echo

# ── Step 1: Verify GPU ──────────────────────────────────────
log "step 1/6: verifying gfx1151 (Strix Halo)"
if command -v rocminfo &>/dev/null; then
    GPU_ARCH=$(rocminfo 2>/dev/null | grep -oP 'gfx\d+' | head -1 || true)
else
    if lspci 2>/dev/null | grep -q "Strix Halo\|Radeon 8060S"; then
        GPU_ARCH="gfx1151"
    else
        GPU_ARCH=""
    fi
fi
if [[ "$GPU_ARCH" != "gfx1151" ]]; then
    if [[ -n "$GPU_ARCH" ]]; then
        warn "detected $GPU_ARCH — this fast-install ships gfx1151 binaries only"
        warn "for your GPU, use ./install-source.sh (builds from source, ~4 hours)"
        exit 1
    else
        warn "could not detect GPU. if you're sure this is a Strix Halo, set GPU_ARCH=gfx1151 and re-run"
        exit 1
    fi
fi
ok "GPU: $GPU_ARCH"

# ── Step 2: ROCm userspace ──────────────────────────────────
log "step 2/6: ROCm userspace (pacman)"
if ! command -v hipconfig &>/dev/null || [[ ! -d /opt/rocm ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
        warn "dry-run: would install rocm-hip-sdk"
    else
        sudo pacman -S --noconfirm --needed rocm-hip-sdk rocm-opencl-sdk
    fi
    ok "rocm-hip-sdk installed"
else
    ok "ROCm already present ($(hipconfig --version 2>/dev/null || echo unknown))"
fi

# ── Step 3: Fetch release manifest ──────────────────────────
log "step 3/6: fetching release from $SOURCE"
WORK=$(mktemp -d)
trap "rm -rf $WORK" EXIT
cd "$WORK"

ASSETS=(
    bitnet_decode-rdna.tar.zst
    agent_cpp.tar.zst
    librocm_cpp-rdna.tar.zst
    halo-1bit-2b.tar.zst
    SHA256SUMS
)
OPTIONAL_ASSETS=(
    man-cave-rdna.tar.zst       # FTXUI TUI — not always shipped
)

for a in "${ASSETS[@]}"; do
    if [[ $DRY_RUN -eq 1 ]]; then
        log "dry-run: would fetch $SOURCE/$a"
        continue
    fi
    curl --fail-with-body -sLO "$SOURCE/$a" || die "fetch failed: $a"
done
for a in "${OPTIONAL_ASSETS[@]}"; do
    if [[ $DRY_RUN -eq 1 ]]; then
        log "dry-run: would try $SOURCE/$a (optional)"
        continue
    fi
    curl --fail-with-body -sLO "$SOURCE/$a" 2>/dev/null || log "optional asset $a not in release — skipping"
done

# GPG signature is optional (skipped if missing or --skip-gpg)
if [[ $DRY_RUN -eq 0 && $SKIP_GPG -eq 0 ]]; then
    curl --fail-with-body -sLO "$SOURCE/SHA256SUMS.asc" 2>/dev/null || warn "no GPG signature found at $SOURCE — skipping sig check"
fi
ok "assets downloaded"

# ── Step 4: Verify integrity ────────────────────────────────
if [[ $DRY_RUN -eq 0 ]]; then
    log "step 4/6: verifying SHA256SUMS"
    sha256sum -c SHA256SUMS --ignore-missing --quiet || die "checksum verification FAILED"
    ok "checksums match"

    if [[ -f SHA256SUMS.asc && $SKIP_GPG -eq 0 ]]; then
        if gpg --verify SHA256SUMS.asc SHA256SUMS 2>/dev/null; then
            ok "GPG signature verified"
        else
            warn "GPG signature invalid or architect's key not imported"
            warn "import via: curl https://github.com/stampby.gpg | gpg --import"
            read -rp "continue anyway? (y/N): " cont
            [[ "$cont" =~ ^[Yy]$ ]] || die "aborted on unverified signature"
        fi
    fi
else
    warn "dry-run: skipping integrity check"
fi

# ── Step 5: Install ─────────────────────────────────────────
log "step 5/6: installing to $INSTALL_PREFIX and $MODELS_DIR"
if [[ $DRY_RUN -eq 0 ]]; then
    sudo mkdir -p "$INSTALL_PREFIX/bin" "$INSTALL_PREFIX/lib"
    mkdir -p "$MODELS_DIR"

    sudo tar --zstd -xf bitnet_decode-rdna.tar.zst -C "$INSTALL_PREFIX/"
    sudo tar --zstd -xf agent_cpp.tar.zst          -C "$INSTALL_PREFIX/"
    sudo tar --zstd -xf librocm_cpp-rdna.tar.zst   -C "$INSTALL_PREFIX/"
    [[ -f man-cave-rdna.tar.zst ]] && sudo tar --zstd -xf man-cave-rdna.tar.zst -C "$INSTALL_PREFIX/"
    tar --zstd -xf halo-1bit-2b.tar.zst            -C "$MODELS_DIR/" --strip-components=1
    sudo ldconfig
else
    warn "dry-run: skipping install"
fi
ok "installed"

# ── Step 6: systemd units ───────────────────────────────────
log "step 6/6: systemd units"
if [[ $DRY_RUN -eq 0 ]]; then
    sudo tee /etc/systemd/system/halo-bitnet.service >/dev/null <<EOF
[Unit]
Description=halo-ai bitnet decode server
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_PREFIX/bin/bitnet_decode $MODELS_DIR/halo-1bit-2b.h1b --server 8080
Restart=on-failure
RestartSec=3
User=$USER

[Install]
WantedBy=multi-user.target
EOF
    sudo tee /etc/systemd/system/halo-agent.service >/dev/null <<EOF
[Unit]
Description=halo-ai agent runtime
After=halo-bitnet.service
Wants=halo-bitnet.service

[Service]
Type=simple
ExecStart=$INSTALL_PREFIX/bin/agent_cpp
Restart=on-failure
RestartSec=3
User=$USER

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable --now halo-bitnet.service
    sleep 2
    sudo systemctl enable --now halo-agent.service
    ok "systemd units enabled"
else
    warn "dry-run: skipping systemd"
fi

echo
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  done. the 1-bit monster is awake.                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo
echo "  curl http://localhost:8080/v1/models"
echo "  journalctl --user -fu halo-bitnet"
echo "  man-cave                     # FTXUI dashboard"
