#!/bin/bash
# ============================================================
# Halo AI Core — Sandbox Test & Demo Recording
# "Prove it works or it doesn't ship." — the architect
# ============================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CAST_FILE="$SCRIPT_DIR/halo-ai-core-install.cast"
LEMONADE_URL="http://localhost:13305"

banner() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

pass() { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; FAILURES=$((FAILURES + 1)); }
info() { echo -e "  ${BLUE}→${NC} $1"; }

FAILURES=0

# ============================================================
banner "PHASE 1: SANDBOX — Clean Container Dry Run"
# ============================================================

info "Spinning up fresh Arch Linux container..."
podman rm -f halo-sandbox 2>/dev/null || true

podman run -d --name halo-sandbox \
    -v "$SCRIPT_DIR:/src:ro" \
    archlinux/archlinux:latest \
    sleep 300

info "Installing base dependencies in sandbox..."
podman exec halo-sandbox pacman -Syu --noconfirm base-devel git sudo 2>&1 | tail -1

info "Creating test user..."
podman exec halo-sandbox bash -c '
    useradd -m -G wheel testuser 2>/dev/null || true
    echo "testuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/testuser
'

info "Running install.sh --dry-run in sandbox..."
echo ""
podman exec -u testuser halo-sandbox bash -c '
    cp -r /src ~/halo-ai-core
    cd ~/halo-ai-core
    chmod +x install.sh
    ./install.sh --dry-run 2>&1
'
DRY_EXIT=$?

echo ""
if [ $DRY_EXIT -eq 0 ]; then
    pass "Dry run completed successfully in clean container"
else
    fail "Dry run failed (exit code: $DRY_EXIT)"
fi

info "Running install.sh --status in sandbox..."
podman exec -u testuser halo-sandbox bash -c '
    cd ~/halo-ai-core
    ./install.sh --status 2>&1
' || true

info "Running install.sh --help in sandbox..."
podman exec -u testuser halo-sandbox bash -c '
    cd ~/halo-ai-core
    ./install.sh --help 2>&1
' || true

info "Cleaning up sandbox..."
podman rm -f halo-sandbox 2>/dev/null

pass "Sandbox phase complete"

# ============================================================
banner "PHASE 2: BARE METAL — Service Verification"
# ============================================================

info "Checking all services..."
for svc in lemonade-server caddy gaia gaia-ui; do
    STATUS=$(systemctl is-active "$svc" 2>/dev/null || echo "inactive")
    if [ "$STATUS" = "active" ]; then
        pass "$svc — running"
    else
        fail "$svc — $STATUS"
    fi
done

info "Checking Caddy landing page..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    pass "Landing page (:80) — HTTP $HTTP_CODE"
else
    fail "Landing page (:80) — HTTP $HTTP_CODE"
fi

info "Checking Lemonade API..."
HEALTH=$(curl -s "$LEMONADE_URL/api/v1/health" 2>/dev/null)
VER=$(echo "$HEALTH" | python3 -c "import json,sys; print(json.load(sys.stdin)['version'])" 2>/dev/null || echo "error")
if [ "$VER" != "error" ]; then
    pass "Lemonade API — v$VER"
else
    fail "Lemonade API not responding"
fi

info "Checking Gaia API..."
GAIA_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5050 2>/dev/null || echo "000")
if [ "$GAIA_CODE" != "000" ]; then
    pass "Gaia API (:5000) — responding"
else
    fail "Gaia API not responding"
fi

info "Checking reverse proxies..."
for port in 13306 4201 5001 8081; do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port" 2>/dev/null || echo "000")
    if [ "$CODE" != "000" ]; then
        pass "Caddy proxy :$port — HTTP $CODE"
    else
        fail "Caddy proxy :$port — not responding"
    fi
done

# ============================================================
banner "PHASE 3: MODEL & BENCHMARKS"
# ============================================================

info "Checking loaded models..."
MODELS=$(curl -s "$LEMONADE_URL/api/v1/health" 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
models = d.get('all_models_loaded',[])
if models:
    for m in models:
        print(f'  {m}')
else:
    print('  (none loaded)')
" 2>/dev/null || echo "  (API error)")
echo "$MODELS"

# Load model if not loaded
LOADED=$(curl -s "$LEMONADE_URL/api/v1/health" 2>/dev/null | python3 -c "import json,sys; print(len(json.load(sys.stdin).get('all_models_loaded',[])))" 2>/dev/null || echo "0")
if [ "$LOADED" = "0" ]; then
    info "Loading Qwen3-Coder-30B-A3B on ROCm..."
    curl -s -X POST "$LEMONADE_URL/api/v1/load" \
        -H "Content-Type: application/json" \
        -d '{"model_name": "Qwen3-Coder-30B-A3B-Instruct-GGUF", "llamacpp_backend": "rocm", "ctx_size": 4096}' | \
        python3 -c "import json,sys; d=json.load(sys.stdin); print(f'  {d[\"status\"]}: {d[\"model_name\"]}')" 2>/dev/null
fi

echo ""
info "Running benchmark suite through Lemonade API..."
echo ""
echo -e "${CYAN}  ┌────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}  │  LEMONADE SDK BENCHMARK — Strix Halo (Ryzen AI MAX+ 395 / 8060S)     │${NC}"
echo -e "${CYAN}  └────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""

run_bench() {
    local label="$1"
    local prompt="$2"
    local tokens="$3"

    RESULT=$(curl -s "$LEMONADE_URL/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"Qwen3-Coder-30B-A3B-Instruct-GGUF\",
            \"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}],
            \"max_tokens\": $tokens,
            \"temperature\": 0.7
        }" 2>/dev/null)

    echo "$RESULT" | python3 -c "
import json,sys
d=json.load(sys.stdin)
t=d['timings']
print(f'  {\"$label\":<12} │ pp: {t[\"prompt_n\"]:>4} tok │ gen: {t[\"predicted_n\"]:>5} tok │ {t[\"prompt_per_second\"]:>7.1f} pp tok/s │ {t[\"predicted_per_second\"]:>5.1f} gen tok/s │ TTFT: {t[\"prompt_ms\"]:>6.0f}ms │ total: {t[\"predicted_ms\"]/1000:>5.1f}s')
" 2>/dev/null || fail "Benchmark '$label' failed"
}

echo "  Test         │ Prompt      │ Generation   │ Prompt Speed  │ Gen Speed     │ TTFT        │ Time"
echo "  ─────────────┼─────────────┼──────────────┼───────────────┼───────────────┼─────────────┼──────────"

run_bench "Short"     "Explain quantum computing simply."                                                      256
run_bench "Medium"    "Design a microservices architecture for a multiplayer game backend with matchmaking."    512
run_bench "Long"      "Write a complete Python B-tree implementation with insert delete search and range query." 1024
run_bench "Sustained" "Write a comprehensive guide on building a distributed database from scratch in Rust."    2048

echo ""

# System stats
info "System stats during inference..."
curl -s "$LEMONADE_URL/api/v1/system-stats" 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(f'  RAM: {d[\"memory_gb\"]:.1f} GB  |  VRAM: {d[\"vram_gb\"]:.1f} GB  |  GPU: {d[\"gpu_percent\"]}%  |  NPU: {d.get(\"npu_percent\", \"n/a\")}')
" 2>/dev/null

# ============================================================
banner "PHASE 4: ACCESS URLS & QR CODE"
# ============================================================

# Get IPs
LAN_IP=$(ip -o -4 addr show | grep -v "127.0.0.1" | awk '{print $4}' | cut -d/ -f1 | head -1)
HOSTNAME=$(cat /proc/sys/kernel/hostname)

echo -e "  ${GREEN}┌──────────────────────────────────────────────────────────────────┐${NC}"
echo -e "  ${GREEN}│                    HALO AI CORE v0.9.1                           │${NC}"
echo -e "  ${GREEN}│              designed and built by the architect                  │${NC}"
echo -e "  ${GREEN}├──────────────────────────────────────────────────────────────────┤${NC}"
echo -e "  ${GREEN}│                                                                  │${NC}"
echo -e "  ${GREEN}│  Landing Page:    http://${LAN_IP}                           │${NC}"
echo -e "  ${GREEN}│  Lemonade UI:     http://${LAN_IP}:13306                     │${NC}"
echo -e "  ${GREEN}│  Gaia Agents:     http://${LAN_IP}:4201                      │${NC}"
echo -e "  ${GREEN}│  Gaia API:        http://${LAN_IP}:5001/docs                 │${NC}"
echo -e "  ${GREEN}│  LLaMA API:       http://${LAN_IP}:8081/v1/models            │${NC}"
echo -e "  ${GREEN}│  SearXNG:         http://${LAN_IP}:8889                      │${NC}"
echo -e "  ${GREEN}│                                                                  │${NC}"
echo -e "  ${GREEN}│  SSH:  ssh bcloud@${LAN_IP}                                 │${NC}"
echo -e "  ${GREEN}│                                                                  │${NC}"
echo -e "  ${GREEN}└──────────────────────────────────────────────────────────────────┘${NC}"
echo ""

# WireGuard QR
if [ -f /etc/wireguard/client1.conf ]; then
    info "WireGuard VPN — scan with your phone:"
    echo ""
    echo -e "  ${YELLOW}┌──────────────────────────────────────────┐${NC}"
    echo -e "  ${YELLOW}│  SCAN THIS WITH YOUR PHONE               │${NC}"
    echo -e "  ${YELLOW}│  WireGuard app → + → Scan from QR Code   │${NC}"
    echo -e "  ${YELLOW}└──────────────────────────────────────────┘${NC}"
    echo ""
    sudo qrencode -t ansiutf8 < /etc/wireguard/client1.conf 2>/dev/null || warn "qrencode not installed"
    echo ""
    echo -e "  Phone VPN IP:  ${GREEN}10.100.0.2${NC}"
    echo -e "  Lemonade:      ${GREEN}http://10.100.0.1:13306${NC}"
    echo -e "  Gaia:          ${GREEN}http://10.100.0.1:4201${NC}"
    echo ""
else
    info "WireGuard not configured — run install.sh to set up VPN"
fi

# ============================================================
banner "RESULTS"
# ============================================================

if [ $FAILURES -eq 0 ]; then
    echo -e "  ${GREEN}ALL TESTS PASSED${NC} — zero failures"
    echo ""
    echo -e "  \"I am inevitable.\" — stamped by the architect"
else
    echo -e "  ${RED}$FAILURES FAILURE(S)${NC} — check output above"
fi

echo ""
echo -e "  Cast file: ${CYAN}$CAST_FILE${NC}"
echo -e "  Replay:    ${CYAN}asciinema play $CAST_FILE${NC}"
echo ""
