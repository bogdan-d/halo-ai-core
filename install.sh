#!/bin/bash
# ============================================================
# Halo AI Core — Install Script
# Designed and built by the architect
#
# "I know kung fu." — Neo, The Matrix
#
# Core services for AMD Strix Halo bare-metal AI platform
# Components: ROCm, Caddy, llama.cpp, Lemonade SDK, Gaia SDK
# ============================================================
set -e

VERSION="0.9.0"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="/tmp/halo-ai-core-install.log"
DRY_RUN=false
SKIP_ROCM=false
SKIP_CADDY=false
SKIP_LLAMA=false
SKIP_LEMONADE=false
SKIP_GAIA=false
PYTHON_VERSION="3.13.4"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    echo "Halo AI Core v${VERSION} — Install Script"
    echo ""
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run       Show what would be installed without doing it"
    echo "  --yes-all       Skip all confirmation prompts"
    echo "  --skip-rocm     Skip ROCm installation"
    echo "  --skip-caddy    Skip Caddy installation"
    echo "  --skip-llama    Skip llama.cpp build"
    echo "  --skip-lemonade Skip Lemonade SDK"
    echo "  --skip-gaia     Skip Gaia SDK"
    echo "  --status        Show current install status"
    echo "  -h, --help      Show this help"
    exit 0
}

TOTAL_STEPS=8
CURRENT_STEP=0

progress_bar() {
    local pct=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    local filled=$((pct / 5))
    local empty=$((20 - filled))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    echo -e "${BLUE}  [${bar}] ${pct}% — Step ${CURRENT_STEP}/${TOTAL_STEPS}${NC}"
}

step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ▸ Step ${CURRENT_STEP}/${TOTAL_STEPS}: $1${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    progress_bar
    echo ""
    echo "[$(date '+%H:%M:%S')] Step ${CURRENT_STEP}/${TOTAL_STEPS}: $1" >> "$LOG_FILE"
}

spinner() {
    local pid=$1
    local msg=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${BLUE}${spin:i++%${#spin}:1}${NC} %s" "$msg"
        sleep 0.1
    done
    printf "\r  ${GREEN}✓${NC} %s\n" "$msg"
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

check_status() {
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║       Halo AI Core — Status          ║"
    echo "╚══════════════════════════════════════╝"
    echo ""

    # ROCm
    if command -v rocminfo &>/dev/null || [ -f /opt/rocm/bin/rocminfo ]; then
        GPU=$(/opt/rocm/bin/rocminfo 2>/dev/null | grep "Marketing Name" | grep -v CPU | head -1 | sed 's/.*: *//')
        echo -e "  ROCm:     ${GREEN}installed${NC} — $GPU"
    else
        echo -e "  ROCm:     ${RED}not installed${NC}"
    fi

    # Caddy
    if systemctl is-active caddy &>/dev/null; then
        echo -e "  Caddy:    ${GREEN}running${NC} — $(caddy version 2>/dev/null)"
    elif command -v caddy &>/dev/null; then
        echo -e "  Caddy:    ${YELLOW}installed but not running${NC}"
    else
        echo -e "  Caddy:    ${RED}not installed${NC}"
    fi

    # llama.cpp
    if [ -f /usr/local/bin/llama-server ]; then
        VER=$(/usr/local/bin/llama-server --version 2>&1 | grep version | head -1)
        echo -e "  llama.cpp: ${GREEN}installed${NC} — $VER"
    else
        echo -e "  llama.cpp: ${RED}not installed${NC}"
    fi

    # Lemonade
    if [ -f "$HOME/lemonade-env/bin/lemonade" ]; then
        VER=$($HOME/lemonade-env/bin/pip show lemonade-sdk 2>/dev/null | grep Version | cut -d' ' -f2)
        echo -e "  Lemonade: ${GREEN}installed${NC} — v$VER"
    else
        echo -e "  Lemonade: ${RED}not installed${NC}"
    fi

    # Gaia
    if [ -f "$HOME/gaia-env/bin/gaia" ]; then
        VER=$($HOME/gaia-env/bin/gaia --version 2>/dev/null)
        echo -e "  Gaia:     ${GREEN}installed${NC} — v$VER"
    else
        echo -e "  Gaia:     ${RED}not installed${NC}"
    fi

    # Services
    echo ""
    echo "  Services:"
    for svc in caddy sshd llama-server lemonade-ui gaia-ui gaia; do
        STATUS=$(systemctl is-enabled $svc 2>/dev/null || echo "missing")
        ACTIVE=$(systemctl is-active $svc 2>/dev/null || echo "inactive")
        if [ "$STATUS" = "enabled" ]; then
            echo -e "    $svc: ${GREEN}$STATUS${NC} ($ACTIVE)"
        else
            echo -e "    $svc: ${YELLOW}$STATUS${NC} ($ACTIVE)"
        fi
    done
    echo ""
    exit 0
}

# Parse args
YES_ALL=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)     DRY_RUN=true; shift ;;
        --yes-all)     YES_ALL=true; shift ;;
        --skip-rocm)   SKIP_ROCM=true; shift ;;
        --skip-caddy)  SKIP_CADDY=true; shift ;;
        --skip-llama)  SKIP_LLAMA=true; shift ;;
        --skip-lemonade) SKIP_LEMONADE=true; shift ;;
        --skip-gaia)   SKIP_GAIA=true; shift ;;
        --status)      check_status ;;
        -h|--help)     usage ;;
        *)             err "Unknown option: $1"; usage ;;
    esac
done

# ============================================================
echo ""
echo "╔══════════════════════════════════════╗"
echo "║   Halo AI Core v${VERSION} — Installer    ║"
echo "║   Designed and built by the architect║"
echo "╚══════════════════════════════════════╝"
echo ""

if $DRY_RUN; then
    warn "DRY RUN — nothing will be installed"
    echo ""
fi

# Pre-flight checks
if [ "$(id -u)" -eq 0 ]; then
    err "Do not run as root. Run as your user with sudo access."
    exit 1
fi

if ! command -v pacman &>/dev/null; then
    if $DRY_RUN; then
        warn "pacman not found — dry-run will show planned actions only"
    else
        err "This script requires Arch Linux (pacman not found)"
        exit 1
    fi
fi

if ! sudo -n true 2>/dev/null; then
    if $DRY_RUN; then
        warn "sudo not available — dry-run will show planned actions only"
    else
        err "Passwordless sudo required. Run: echo '$USER ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/$USER"
        exit 1
    fi
fi

# Confirm
if ! $YES_ALL && ! $DRY_RUN; then
    info "This will install Halo AI Core services on $(hostname)"
    read -p "Continue? [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 0
fi

# ============================================================
# 1. BASE PACKAGES
# ============================================================
step "Base Packages"
BASE_PKGS="base-devel git openssh networkmanager curl wget htop nano cmake make nodejs npm"

if $DRY_RUN; then
    info "Would install: $BASE_PKGS"
else
    # shellcheck disable=SC2086
    sudo pacman -Sy --needed --noconfirm ${BASE_PKGS} >> "$LOG_FILE" 2>&1 &
    spinner $! "Installing base packages..."
    sudo systemctl enable --now NetworkManager sshd >> "$LOG_FILE" 2>&1
    log "Base packages installed"
fi

# ============================================================
# 2. ROCm
# ============================================================
if ! $SKIP_ROCM; then
    step "ROCm GPU Stack"
    ROCM_PKGS="rocm-hip-sdk rocm-opencl-sdk hip-runtime-amd rocminfo rocwmma vulkan-headers vulkan-icd-loader vulkan-radeon shaderc glslang"

    if $DRY_RUN; then
        info "Would install: $ROCM_PKGS"
    else
        # shellcheck disable=SC2086
        sudo pacman -S --needed --noconfirm ${ROCM_PKGS} >> "$LOG_FILE" 2>&1 &
        spinner $! "Installing ROCm packages (this takes a few minutes)..."

        # ROCm PATH and env
        sudo tee /etc/profile.d/rocm.sh > /dev/null << 'ROCM_ENV'
export PATH=$PATH:/opt/rocm/bin
export ROCBLAS_USE_HIPBLASLT=1
export PYTORCH_ROCM_ARCH=gfx1151
export HSA_OVERRIDE_GFX_VERSION=11.5.1
export TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
export IOMMU=pt
ROCM_ENV

        # Add user to video/render
        sudo usermod -aG video,render "$USER"

        # Source it now
        export PATH=$PATH:/opt/rocm/bin

        log "ROCm installed — $(/opt/rocm/bin/rocminfo 2>/dev/null | grep 'Marketing Name' | grep -v CPU | head -1 | sed 's/.*: *//')"
    fi
else
    warn "Skipping ROCm"
fi

# ============================================================
# 3. CADDY
# ============================================================
if ! $SKIP_CADDY; then
    step "Caddy Reverse Proxy"

    if $DRY_RUN; then
        info "Would install: caddy"
    else
        sudo pacman -S --needed --noconfirm caddy >> "$LOG_FILE" 2>&1
        sudo mkdir -p /etc/caddy

        sudo tee /etc/caddy/Caddyfile > /dev/null << 'CADDYFILE'
# Halo AI Core — Caddy Reverse Proxy
# Drop configs in /etc/caddy/conf.d/*.caddy

:80 {
    respond "halo-ai core — {hostname}"
}

import /etc/caddy/conf.d/*.caddy
CADDYFILE

        sudo mkdir -p /etc/caddy/conf.d
        sudo systemctl enable --now caddy >> "$LOG_FILE" 2>&1
        log "Caddy installed and running"
    fi
else
    warn "Skipping Caddy"
fi

# ============================================================
# 4. PYTHON (via pyenv for 3.13 compatibility)
# ============================================================
step "Python ${PYTHON_VERSION}"

if $DRY_RUN; then
    info "Would install Python ${PYTHON_VERSION} via pyenv"
else
    if [ ! -f "$HOME/.pyenv/versions/${PYTHON_VERSION}/bin/python3" ]; then
        sudo pacman -S --needed --noconfirm tk sqlite openssl zlib xz bzip2 libffi readline ncurses >> "$LOG_FILE" 2>&1

        if [ ! -d "$HOME/.pyenv" ]; then
            # Install pyenv via git (safer than curl|bash)
            git clone https://github.com/pyenv/pyenv.git "$HOME/.pyenv" >> "$LOG_FILE" 2>&1
            git clone https://github.com/pyenv/pyenv-virtualenv.git "$HOME/.pyenv/plugins/pyenv-virtualenv" >> "$LOG_FILE" 2>&1
        fi

        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        # shellcheck disable=SC1090
        source <("$PYENV_ROOT/bin/pyenv" init -)

        pyenv install -s "${PYTHON_VERSION}" >> "$LOG_FILE" 2>&1
        log "Python ${PYTHON_VERSION} installed via pyenv"
    else
        log "Python ${PYTHON_VERSION} already installed"
    fi
fi

PYTHON_BIN="$HOME/.pyenv/versions/${PYTHON_VERSION}/bin/python3"

# ============================================================
# 5. LLAMA.CPP
# ============================================================
if ! $SKIP_LLAMA; then
    step "llama.cpp (ROCm + Vulkan)"

    if $DRY_RUN; then
        info "Would clone and build llama.cpp with HIP + Vulkan"
    else
        export PATH=$PATH:/opt/rocm/bin
        export HIP_PATH=/opt/rocm
        export ROCM_PATH=/opt/rocm

        if [ ! -d "$HOME/llama.cpp" ]; then
            git clone https://github.com/ggerganov/llama.cpp.git "$HOME/llama.cpp" >> "$LOG_FILE" 2>&1
        else
            cd "$HOME/llama.cpp" && git pull >> "$LOG_FILE" 2>&1
        fi

        cd "$HOME/llama.cpp"

        # ── gfx1151 MMQ kernel fix (issue #21284) ──
        # Stock llama.cpp has suboptimal MMQ parameters that exceed
        # the 256 VGPR register limit on RDNA 3.5, costing ~20% perf.
        # Patch: mmq_x=48, mmq_y=64, nwarps=4
        log "Applying gfx1151 performance patches..."
        if grep -q 'mmq_x = 64' ggml/src/ggml-cuda/mmq.cu 2>/dev/null; then
            sed -i 's/mmq_x = 64/mmq_x = 48/g' ggml/src/ggml-cuda/mmq.cu
            sed -i 's/mmq_y = 128/mmq_y = 64/g' ggml/src/ggml-cuda/mmq.cu
            sed -i 's/nwarps = 8/nwarps = 4/g' ggml/src/ggml-cuda/mmq.cu
            log "MMQ kernel parameters patched for gfx1151"
        else
            info "MMQ patch already applied or file structure changed — skipping"
        fi

        # Fast math intrinsics for MoE routing and SiLU
        if grep -q 'expf(' ggml/src/ggml-cuda/common.cuh 2>/dev/null; then
            sed -i 's/expf(\([^)]*\))/__expf(\1)/g' ggml/src/ggml-cuda/fattn-common.cuh 2>/dev/null || true
            log "Fast math intrinsics applied"
        fi

        rm -rf build
        cmake -B build \
            -DGGML_HIP=ON \
            -DGGML_VULKAN=ON \
            -DGGML_HIP_ROCWMMA_FATTN=ON \
            -DAMDGPU_TARGETS=gfx1151 \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_HIP_COMPILER=/opt/rocm/bin/amdclang++ \
            >> "$LOG_FILE" 2>&1

        cmake --build build --config Release -j"$(nproc)" >> "$LOG_FILE" 2>&1 &
        spinner $! "Compiling llama.cpp (this is the big one — be patient)..."

        # Stop running instances before overwriting binaries
        sudo systemctl stop llama-server.service 2>/dev/null || true
        sudo cp build/bin/llama-server /usr/local/bin/
        sudo cp build/bin/llama-cli /usr/local/bin/
        sudo cp build/bin/llama-bench /usr/local/bin/

        # Systemd service
        sudo tee /usr/lib/systemd/system/llama-server.service > /dev/null << LLAMA_SVC
[Unit]
Description=llama.cpp Inference Server
After=network.target

[Service]
Type=simple
User=${USER}
Environment=PATH=/usr/local/bin:/opt/rocm/bin:/usr/bin
Environment=ROCBLAS_USE_HIPBLASLT=1
Environment=HSA_OVERRIDE_GFX_VERSION=11.5.1
Environment=TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
Environment=PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
ExecStart=/usr/local/bin/llama-server --host 127.0.0.1 --port 8080 --n-gpu-layers 999
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
LLAMA_SVC

        # Caddy route
        sudo tee /etc/caddy/conf.d/llama.caddy > /dev/null << 'LLAMA_CADDY'
:8081 {
    reverse_proxy localhost:8080
}
LLAMA_CADDY

        sudo systemctl daemon-reload
        sudo systemctl enable llama-server >> "$LOG_FILE" 2>&1
        sudo systemctl reload caddy >> "$LOG_FILE" 2>&1

        log "llama.cpp built and installed — $(/usr/local/bin/llama-server --version 2>&1 | grep version | head -1)"
    fi
else
    warn "Skipping llama.cpp"
fi

# ============================================================
# 6. LEMONADE SDK
# ============================================================
if ! $SKIP_LEMONADE; then
    step "Lemonade SDK"

    if $DRY_RUN; then
        info "Would install lemonade-sdk in ~/lemonade-env"
    else
        if [ ! -d "$HOME/lemonade-env" ]; then
            "$PYTHON_BIN" -m venv "$HOME/lemonade-env"
        fi

        "$HOME/lemonade-env/bin/pip" install --upgrade pip >> "$LOG_FILE" 2>&1
        "$HOME/lemonade-env/bin/pip" install lemonade-sdk >> "$LOG_FILE" 2>&1 &
        spinner $! "Installing Lemonade SDK..."

        # Systemd service
        sudo tee /usr/lib/systemd/system/lemonade.service > /dev/null << LEM_SVC
[Unit]
Description=Lemonade SDK Server
After=network.target

[Service]
Type=simple
User=${USER}
Environment=PATH=${HOME}/lemonade-env/bin:/usr/local/bin:/opt/rocm/bin:/usr/bin
Environment=ROCBLAS_USE_HIPBLASLT=1
Environment=HSA_OVERRIDE_GFX_VERSION=11.5.1
WorkingDirectory=${HOME}
ExecStart=${HOME}/lemonade-env/bin/lemonade --tools llama-server --port 13305
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
LEM_SVC

        sudo systemctl daemon-reload
        sudo systemctl enable lemonade >> "$LOG_FILE" 2>&1

        VER=$("$HOME/lemonade-env/bin/pip" show lemonade-sdk 2>/dev/null | grep Version | cut -d' ' -f2)
        log "Lemonade SDK v$VER installed"
    fi
else
    warn "Skipping Lemonade SDK"
fi

# ============================================================
# 7. GAIA SDK
# ============================================================
if ! $SKIP_GAIA; then
    step "Gaia SDK"

    if $DRY_RUN; then
        info "Would install amd-gaia in ~/gaia-env"
    else
        if [ ! -d "$HOME/gaia" ]; then
            git clone https://github.com/amd/gaia.git "$HOME/gaia" >> "$LOG_FILE" 2>&1 || \
            git clone https://github.com/bong-water-water-bong/gaia.git "$HOME/gaia" >> "$LOG_FILE" 2>&1
        fi

        if [ ! -d "$HOME/gaia-env" ]; then
            "$PYTHON_BIN" -m venv "$HOME/gaia-env"
        fi

        "$HOME/gaia-env/bin/pip" install --upgrade pip >> "$LOG_FILE" 2>&1
        cd "$HOME/gaia"
        "$HOME/gaia-env/bin/pip" install -e . >> "$LOG_FILE" 2>&1 &
        spinner $! "Installing Gaia SDK (includes PyTorch — grab a coffee)..."

        # Systemd service
        sudo tee /usr/lib/systemd/system/gaia.service > /dev/null << GAIA_SVC
[Unit]
Description=Gaia AI Agent Framework
After=network.target llama-server.service

[Service]
Type=simple
User=${USER}
Environment=PATH=${HOME}/gaia-env/bin:/usr/local/bin:/opt/rocm/bin:/usr/bin
Environment=ROCBLAS_USE_HIPBLASLT=1
Environment=HSA_OVERRIDE_GFX_VERSION=11.5.1
WorkingDirectory=${HOME}/gaia
ExecStart=${HOME}/gaia-env/bin/gaia serve
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
GAIA_SVC

        sudo systemctl daemon-reload
        sudo systemctl enable gaia >> "$LOG_FILE" 2>&1

        VER=$("$HOME/gaia-env/bin/gaia" --version 2>/dev/null)
        log "Gaia SDK v$VER installed"
    fi
else
    warn "Skipping Gaia SDK"
fi

# ============================================================
# 8. WEB UIs
# ============================================================
step "Web UIs"

if $DRY_RUN; then
    info "Would configure Lemonade UI (port 13305) and Gaia Agent UI (port 4200)"
else
    # Lemonade Server UI (replaces headless lemonade service)
    sudo tee /usr/lib/systemd/system/lemonade-ui.service > /dev/null << LEM_UI_SVC
[Unit]
Description=Lemonade Server Web UI
After=network.target

[Service]
Type=simple
User=${USER}
Environment=PATH=${HOME}/lemonade-env/bin:/usr/local/bin:/opt/rocm/bin:/usr/bin
Environment=ROCBLAS_USE_HIPBLASLT=1
Environment=HSA_OVERRIDE_GFX_VERSION=11.5.1
WorkingDirectory=${HOME}
ExecStart=${HOME}/lemonade-env/bin/lemonade-server-dev serve --port 13305 --host 127.0.0.1 --llamacpp rocm
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
LEM_UI_SVC

    # Gaia Agent UI
    sudo npm install -g @amd-gaia/agent-ui@latest >> "$LOG_FILE" 2>&1

    sudo tee /usr/lib/systemd/system/gaia-ui.service > /dev/null << GAIA_UI_SVC
[Unit]
Description=Gaia Agent Web UI
After=network.target lemonade-ui.service

[Service]
Type=simple
User=${USER}
Environment=PATH=/usr/local/bin:/usr/bin
WorkingDirectory=${HOME}
ExecStart=/usr/bin/gaia-ui --serve
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
GAIA_UI_SVC

    # Caddy routes for UIs
    sudo tee /etc/caddy/conf.d/lemonade-ui.caddy > /dev/null << 'LEM_UI_CADDY'
:13306 {
    reverse_proxy localhost:13305
}
LEM_UI_CADDY

    sudo tee /etc/caddy/conf.d/gaia-ui.caddy > /dev/null << 'GAIA_UI_CADDY'
:4201 {
    reverse_proxy localhost:4200
}
GAIA_UI_CADDY

    # Disable headless lemonade service in favor of UI version
    sudo systemctl disable lemonade >> "$LOG_FILE" 2>&1 || true

    sudo systemctl daemon-reload
    sudo systemctl enable lemonade-ui gaia-ui >> "$LOG_FILE" 2>&1
    sudo systemctl reload caddy >> "$LOG_FILE" 2>&1

    log "Lemonade UI on :13305 (Caddy :13306) — LLM interaction"
    log "Gaia Agent UI on :4200 (Caddy :4201) — Agent management"
fi

# ============================================================
# DONE
# ============================================================
HOSTNAME=$(hostname)
echo ""
echo "╔══════════════════════════════════════╗"
echo "║     Halo AI Core — Install Done      ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "  \"There is no spoon.\" — The Matrix"
echo ""
echo "  ── YOUR UIs ──────────────────────────────────"
echo ""
echo "  Lemonade (chat with LLMs):"
echo "    Local:  http://localhost:13305"
echo "    SSH:    ssh -L 13305:localhost:13305 $HOSTNAME"
echo "            then open http://localhost:13305"
echo ""
echo "  Gaia (manage agents):"
echo "    Local:  http://localhost:4200"
echo "    SSH:    ssh -L 4200:localhost:4200 $HOSTNAME"
echo "            then open http://localhost:4200"
echo ""
echo "  ── NEXT STEPS ────────────────────────────────"
echo ""
echo "  1. Load a model in Lemonade UI"
echo "  2. Start chatting"
echo "  3. Deploy core agents (optional):"
echo "     https://github.com/stampby/halo-ai-core/blob/main/docs/wiki/Core-Agents.md"
echo ""
echo "  ── VERIFY ────────────────────────────────────"
echo ""
echo "  ./install.sh --status"
echo ""
log "Installation complete."
log "Full log: $LOG_FILE"
echo ""
