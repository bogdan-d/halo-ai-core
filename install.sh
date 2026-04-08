#!/bin/bash
# ============================================================
# Halo AI Core — Install Script
# Designed and built by the architect
#
# "I know kung fu." — Neo, The Matrix
#
# Core services for AMD Strix Halo bare-metal AI platform
# Components: ROCm, Caddy, llama.cpp, Lemonade SDK, Gaia SDK, Claude Code
# ============================================================
set -e

VERSION="0.9.2"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="/tmp/halo-ai-core-install.log"
DRY_RUN=false
SKIP_ROCM=false
SKIP_CADDY=false
SKIP_LLAMA=false
SKIP_LEMONADE=false
SKIP_GAIA=false
SKIP_CLAUDE=false
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
    echo "  --skip-claude   Skip Claude Code"
    echo "  --status        Show current install status"
    echo "  -h, --help      Show this help"
    exit 0
}

# Step count calculated dynamically based on skip flags
CURRENT_STEP=0
calculate_steps() {
    TOTAL_STEPS=3  # base + python + web UIs (always run)
    $SKIP_ROCM     || TOTAL_STEPS=$((TOTAL_STEPS + 1))
    $SKIP_CADDY    || TOTAL_STEPS=$((TOTAL_STEPS + 1))
    $SKIP_LLAMA    || TOTAL_STEPS=$((TOTAL_STEPS + 1))
    $SKIP_LEMONADE || TOTAL_STEPS=$((TOTAL_STEPS + 1))
    $SKIP_GAIA     || TOTAL_STEPS=$((TOTAL_STEPS + 1))
    $SKIP_CLAUDE   || TOTAL_STEPS=$((TOTAL_STEPS + 1))
}

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
    if command -v lemonade &>/dev/null; then
        VER=$(lemonade --version 2>/dev/null || echo "installed")
        echo -e "  Lemonade: ${GREEN}installed${NC} — $VER"
    else
        echo -e "  Lemonade: ${RED}not installed${NC}"
    fi

    # Gaia
    if command -v gaia &>/dev/null || [ -f "$HOME/gaia-env/bin/gaia" ]; then
        VER=$(gaia --version 2>/dev/null || $HOME/gaia-env/bin/gaia --version 2>/dev/null || echo "installed")
        echo -e "  Gaia:     ${GREEN}installed${NC} — v$VER"
    else
        echo -e "  Gaia:     ${RED}not installed${NC}"
    fi

    # Claude Code
    if command -v claude &>/dev/null; then
        echo -e "  Claude:   ${GREEN}installed${NC}"
    else
        echo -e "  Claude:   ${RED}not installed${NC}"
    fi

    # Services
    echo ""
    echo "  Services:"
    for svc in caddy sshd llama-server lemond gaia-ui gaia; do
        STATUS=$(systemctl is-enabled $svc 2>/dev/null || echo "missing")
        ACTIVE=$(systemctl is-active $svc 2>/dev/null || true); ACTIVE=${ACTIVE:-inactive}
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
        --skip-claude) SKIP_CLAUDE=true; shift ;;
        --status)      check_status ;;
        -h|--help)     usage ;;
        *)             err "Unknown option: $1"; usage ;;
    esac
done

# ============================================================
calculate_steps
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
    info "This will install Halo AI Core services on $(cat /proc/sys/kernel/hostname)"
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
    sudo pacman -S --needed --noconfirm ${BASE_PKGS} >> "$LOG_FILE" 2>&1 &
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
        sudo mkdir -p /etc/caddy/conf.d
        # Clean stale configs from previous installs to prevent duplicates
        sudo rm -f /etc/caddy/conf.d/*.caddy 2>/dev/null

        sudo tee /etc/caddy/Caddyfile > /dev/null << 'CADDYFILE'
# Halo AI Core — Caddy Reverse Proxy
# Drop configs in /etc/caddy/conf.d/*.caddy

:80 {
    header Content-Type "text/html; charset=utf-8"
    respond `<!DOCTYPE html>
<html><head><title>halo-ai core</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{background:#0a0a0a;color:#e0e0e0;font-family:monospace;display:flex;align-items:center;justify-content:center;height:100vh}
.box{text-align:center}
h1{font-size:2em;margin-bottom:0.5em;color:#00d4ff}
p{margin-bottom:2em;color:#888}
.btn{display:inline-block;margin:0.5em;padding:1em 2em;background:#111;border:1px solid #333;border-radius:8px;color:#00d4ff;text-decoration:none;font-size:1.2em;font-family:monospace;transition:all 0.2s}
.btn:hover{background:#1a1a1a;border-color:#00d4ff}
small{display:block;margin-top:2em;color:#444}
</style></head><body><div class="box">
<h1>halo-ai core</h1>
<p>choose your ui</p>
<a class="btn" href="http://{http.request.host}:13305">lemonade — chat with llms</a>
<a class="btn" href="http://{http.request.host}:4200">gaia — manage agents</a>
<small>designed and built by the architect</small>
</div></body></html>`
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

        # Systemd service (fallback — Lemonade is primary)
        sudo tee /usr/lib/systemd/system/llama-server.service > /dev/null << LLAMA_SVC
[Unit]
Description=llama.cpp Inference Server (fallback)
After=network.target
Conflicts=lemonade-server.service

[Service]
Type=simple
User=${USER}
Environment=PATH=/usr/local/bin:/opt/rocm/bin:/usr/bin
Environment=ROCBLAS_USE_HIPBLASLT=1
Environment=HSA_OVERRIDE_GFX_VERSION=11.5.1
Environment=TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL=1
Environment=PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
ExecStart=/usr/local/bin/llama-server \\
    --host 127.0.0.1 \\
    --port 8080 \\
    --model ${HOME}/models/default.gguf \\
    --n-gpu-layers 999 \\
    --ctx-size 32768
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
        sudo systemctl reload caddy >> "$LOG_FILE" 2>&1 || warn "Caddy reload failed — check /etc/caddy/conf.d/ for duplicates"

        log "llama.cpp built and installed — $(/usr/local/bin/llama-server --version 2>&1 | grep version | head -1)"
    fi
else
    warn "Skipping llama.cpp"
fi

# ============================================================
# 6. LEMONADE SERVER (native AUR package)
# ============================================================
if ! $SKIP_LEMONADE; then
    step "Lemonade Server"

    if $DRY_RUN; then
        info "Would install lemonade-server from AUR"
    else
        if command -v lemonade &>/dev/null; then
            log "Lemonade already installed — $(lemonade --version 2>/dev/null || echo 'installed')"
        else
            # Need an AUR helper (paru > yay > install yay)
            AUR_HELPER=""
            if command -v paru &>/dev/null; then
                AUR_HELPER="paru"
            elif command -v yay &>/dev/null; then
                AUR_HELPER="yay"
            else
                info "Installing yay (AUR helper)..."
                cd /tmp
                git clone https://aur.archlinux.org/yay.git >> "$LOG_FILE" 2>&1
                cd yay && makepkg -si --noconfirm >> "$LOG_FILE" 2>&1
                cd "$HOME"
                AUR_HELPER="yay"
            fi

            $AUR_HELPER -S --needed --noconfirm lemonade-server >> "$LOG_FILE" 2>&1 &
            spinner $! "Building lemonade-server from AUR (C++ native — this takes a minute)..."
        fi

        # Enable the daemon
        sudo systemctl daemon-reload
        sudo systemctl enable lemond >> "$LOG_FILE" 2>&1 || \
            sudo systemctl enable lemonade-server >> "$LOG_FILE" 2>&1 || true

        VER=$(lemonade --version 2>/dev/null || echo "installed")
        log "Lemonade Server $VER — binaries: lemonade (CLI), lemond (daemon)"
        log "Anthropic API: http://localhost:13305/v1/messages"
        log "OpenAI API:    http://localhost:13305/api/v1/chat/completions"
        log "Ollama API:    http://localhost:13305/api/chat"
    fi
else
    warn "Skipping Lemonade Server"
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

        # Gaia .env — wire to Lemonade as primary backend
        cat > "$HOME/gaia/.env" << GAIA_ENV
# Halo AI Core — Gaia Integration
# Primary: Lemonade server (manages models, llamacpp backend)
LEMONADE_BASE_URL=http://localhost:13305/api/v1

# MCP Server
GAIA_MCP_HOST=localhost
GAIA_MCP_PORT=8765

# Agent routing model (loaded via Lemonade)
AGENT_ROUTING_MODEL=Qwen3-Coder-30B-A3B-Instruct-GGUF
GAIA_ENV

        # Systemd service — Gaia API (OpenAI-compatible endpoint)
        sudo tee /usr/lib/systemd/system/gaia.service > /dev/null << GAIA_SVC
[Unit]
Description=Gaia AI Agent Framework
After=network.target lemonade-server.service
Wants=lemonade-server.service

[Service]
Type=simple
User=${USER}
Environment=PATH=${HOME}/gaia-env/bin:/usr/local/bin:/opt/rocm/bin:/usr/bin
Environment=ROCBLAS_USE_HIPBLASLT=1
Environment=HSA_OVERRIDE_GFX_VERSION=11.5.1
Environment=LEMONADE_BASE_URL=http://localhost:13305/api/v1
WorkingDirectory=${HOME}/gaia
ExecStart=${HOME}/gaia-env/bin/gaia api start --host 127.0.0.1 --port 5000 --no-lemonade-check
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
GAIA_SVC

        sudo systemctl daemon-reload
        sudo systemctl enable gaia >> "$LOG_FILE" 2>&1

        VER=$("$HOME/gaia-env/bin/gaia" --version 2>/dev/null)
        log "Gaia SDK v$VER installed"
        log "Gaia .env created — LEMONADE_BASE_URL=http://localhost:13305/api/v1"
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
    # Lemonade UI is handled by lemond (native AUR package)
    # Clean up old venv-based services from previous installs
    sudo systemctl disable lemonade lemonade-ui >> "$LOG_FILE" 2>&1 || true
    sudo rm -f /usr/lib/systemd/system/lemonade.service 2>/dev/null
    sudo rm -f /usr/lib/systemd/system/lemonade-ui.service 2>/dev/null

    # Gaia Agent UI
    sudo npm install -g @amd-gaia/agent-ui@latest >> "$LOG_FILE" 2>&1

    # Find gaia-ui binary — npm global bin location varies
    GAIA_UI_BIN=$(which gaia-ui 2>/dev/null || npm root -g 2>/dev/null | sed 's|/lib/node_modules|/bin/gaia-ui|' || echo "/usr/local/bin/gaia-ui")

    sudo tee /usr/lib/systemd/system/gaia-ui.service > /dev/null << GAIA_UI_SVC
[Unit]
Description=Gaia Agent Web UI
After=network.target lemonade-server.service
Wants=lemonade-server.service

[Service]
Type=simple
User=${USER}
Environment=PATH=${HOME}/gaia-env/bin:/usr/local/bin:/opt/rocm/bin:/usr/bin:/usr/lib/node_modules/.bin
Environment=NODE_PATH=/usr/lib/node_modules
Environment=ROCBLAS_USE_HIPBLASLT=1
Environment=HSA_OVERRIDE_GFX_VERSION=11.5.1
Environment=LEMONADE_BASE_URL=http://localhost:13305/api/v1
WorkingDirectory=${HOME}/gaia
ExecStart=${GAIA_UI_BIN} --port 4200
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
GAIA_UI_SVC

    sudo systemctl daemon-reload
    sudo systemctl enable gaia-ui >> "$LOG_FILE" 2>&1
    sudo systemctl reload caddy >> "$LOG_FILE" 2>&1 || warn "Caddy reload failed — check /etc/caddy/conf.d/ for duplicates"

    # Install the LLM backend switch script
    sudo cp "$SCRIPT_DIR/halo-llm-switch.sh" /usr/local/bin/halo-llm-switch
    sudo chmod +x /usr/local/bin/halo-llm-switch

    log "Lemonade UI on :13305 — managed by lemond (native service)"
    log "Gaia Agent UI on :4200 — Agent management"
    log "Switch backends: halo-llm-switch [lemonade|llama|status]"
fi

# ============================================================
# 9. CLAUDE CODE
# ============================================================
if ! $SKIP_CLAUDE; then
    step "Claude Code (via Lemonade)"

    if $DRY_RUN; then
        info "Would install Claude Code CLI and configure for Lemonade"
    else
        # Install Claude Code
        if command -v claude &>/dev/null; then
            log "Claude Code already installed — $(claude --version 2>/dev/null || echo 'installed')"
        else
            if command -v npm &>/dev/null; then
                sudo npm install -g @anthropic-ai/claude-code >> "$LOG_FILE" 2>&1 &
                spinner $! "Installing Claude Code..."
                log "Claude Code installed via npm"
            else
                err "npm not found — cannot install Claude Code"
            fi
        fi

        # Verify lemonade launch claude is available
        if command -v lemonade &>/dev/null; then
            log "Claude Code can be launched via: lemonade launch claude"
            log "Or with a model: lemonade launch claude -m <model-name>"
        else
            warn "Lemonade CLI not found — install Lemonade Server first for local model routing"
        fi
    fi
else
    warn "Skipping Claude Code"
fi

# ============================================================
# DONE
# ============================================================
HOSTNAME=$(cat /proc/sys/kernel/hostname)
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
echo "  Claude Code (local AI coding agent):"
echo "    lemonade launch claude -m <model-name>"
echo ""
echo "  ── IMPORTANT ─────────────────────────────────"
echo ""
echo "  Reboot your machine to start all services:"
echo ""
echo "    sudo reboot"
echo ""
echo "  Services are enabled and will start automatically on boot."
echo "  They will NOT run until you reboot."
echo ""
echo "  ── NEXT STEPS (after reboot) ──────────────────"
echo ""
echo "  1. Load a model in Lemonade UI"
echo "  2. Start chatting"
echo "  3. Launch Claude Code with local models:"
echo "     lemonade launch claude -m <model-name>"
echo "  4. Deploy core agents (optional):"
echo "     https://github.com/stampby/halo-ai-core/blob/main/docs/wiki/Core-Agents.md"
echo ""
echo "  ── VERIFY ────────────────────────────────────"
echo ""
echo "  ./install.sh --status"
echo ""

# ============================================================
# WIREGUARD — Remote Access via QR Code
# ============================================================
if ! $DRY_RUN; then
    echo "  ── REMOTE ACCESS (WireGuard VPN) ───────────────"
    echo ""

    sudo pacman -S --needed --noconfirm wireguard-tools qrencode >> "$LOG_FILE" 2>&1

    WG_DIR="/etc/wireguard"
    WG_CONF="$WG_DIR/wg0.conf"

    if [ ! -f "$WG_CONF" ]; then
        SERVER_PRIV=$(wg genkey)
        SERVER_PUB=$(echo "$SERVER_PRIV" | wg pubkey)
        CLIENT_PRIV=$(wg genkey)
        CLIENT_PUB=$(echo "$CLIENT_PRIV" | wg pubkey)
        SERVER_IFACE=$(ip -o -4 route show to default | awk '{print $5}' | head -1)
        # Try public IP first (for remote VPN access), fall back to LAN IP
        SERVER_IP=$(curl -4 -s --max-time 5 https://ifconfig.me 2>/dev/null || \
                    ip -o -4 addr show "$SERVER_IFACE" | awk '{print $4}' | cut -d/ -f1 | head -1)
        LAN_IP=$(ip -o -4 addr show "$SERVER_IFACE" | awk '{print $4}' | cut -d/ -f1 | head -1)
        if [ "$SERVER_IP" = "$LAN_IP" ]; then
            warn "Could not detect public IP — WireGuard Endpoint set to LAN IP ($LAN_IP)"
            warn "For remote access, update Endpoint in /etc/wireguard/client1.conf with your public IP or DDNS"
        fi

        sudo tee "$WG_CONF" > /dev/null << WG_SRV
[Interface]
Address = 10.100.0.1/24
ListenPort = 51820
PrivateKey = $SERVER_PRIV
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $SERVER_IFACE -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $SERVER_IFACE -j MASQUERADE

[Peer]
PublicKey = $CLIENT_PUB
AllowedIPs = 10.100.0.2/32
WG_SRV
        sudo chmod 600 "$WG_CONF"

        CLIENT_CONF=$(mktemp)
        cat > "$CLIENT_CONF" << WG_CLIENT
[Interface]
PrivateKey = $CLIENT_PRIV
Address = 10.100.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUB
Endpoint = $SERVER_IP:51820
AllowedIPs = 10.100.0.0/24
PersistentKeepalive = 25
WG_CLIENT

        sudo sysctl -w net.ipv4.ip_forward=1 >> "$LOG_FILE" 2>&1
        echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-wireguard.conf >> "$LOG_FILE" 2>&1
        sudo systemctl enable --now wg-quick@wg0 >> "$LOG_FILE" 2>&1

        echo ""
        echo "  WireGuard VPN running on 10.100.0.1:51820"
        echo ""
        echo "  ┌──────────────────────────────────────────┐"
        echo "  │  SCAN THIS WITH YOUR PHONE               │"
        echo "  │  WireGuard app → + → Scan from QR Code   │"
        echo "  └──────────────────────────────────────────┘"
        echo ""
        qrencode -t ansiutf8 < "$CLIENT_CONF"
        echo ""
        echo "  Phone VPN IP: 10.100.0.2"
        echo "  Lemonade:     http://10.100.0.1:13305"
        echo "  Gaia:         http://10.100.0.1:4200"
        echo ""
        sudo cp "$CLIENT_CONF" /etc/wireguard/client1.conf
        sudo chmod 600 /etc/wireguard/client1.conf
        rm -f "$CLIENT_CONF"
        log "WireGuard VPN configured — QR code displayed"
    else
        echo "  WireGuard already configured at $WG_CONF"
        echo "  Show QR again: qrencode -t ansiutf8 < /etc/wireguard/client1.conf"
        echo ""
    fi
fi

log "Installation complete."
log "Full log: $LOG_FILE"
echo ""
