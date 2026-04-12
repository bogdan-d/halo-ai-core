#!/bin/bash
# ============================================================
# bench-toolbox — kyuz0-style multi-backend benchmark
# Designed and built by the architect
#
# "Adapt. Improvise. Overcome." — Bear Grylls
#
# Tests all 3 backends: Vulkan, ROCm, CPU
# Same model, same prompts, same reps — let the numbers fight.
#
# Adapted from kyuz0/amd-strix-halo-toolboxes (150 benchmarks)
# Credit: kyuz0 for the framework, u/Look_0ver_There for Vulkan,
#         Zhelgadis for pushing ROCm MoE testing
# ============================================================
set -euo pipefail

API_URL="http://localhost:13305/v1/chat/completions"
MODELS_URL="http://localhost:13305/v1/models"
KERNEL=$(uname -r)
TIMESTAMP=$(date -Iseconds)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/bench-results"
REPS=3
BACKENDS="${1:-all}"  # all, vulkan, rocm, cpu
MODEL_NAME=""
mkdir -p "$OUTPUT_DIR"

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; C='\033[0;36m'; R='\033[0;31m'; NC='\033[0m'; BOLD='\033[1m'

usage() {
    echo "bench-toolbox — multi-backend benchmark"
    echo ""
    echo "Usage: ./bench-toolbox.sh [backends]"
    echo ""
    echo "  all       Test Vulkan + ROCm + CPU (default)"
    echo "  vulkan    Vulkan only"
    echo "  rocm      ROCm/HIP only"
    echo "  cpu       CPU only"
    echo "  vr        Vulkan + ROCm (skip CPU)"
    echo ""
    exit 0
}
[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  bench-toolbox — multi-backend benchmark         ║${NC}"
echo -e "${BOLD}║  \"Let them fight.\" — Dr. Ishiro Serizawa         ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ── System info ──
CPU=$(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
GPU=$(rocm-smi --showproductname 2>/dev/null | grep 'Card Series' | head -1 | awk -F: '{print $NF}' | xargs)
ROCM_VER=$(cat /opt/rocm/.info/version 2>/dev/null || echo 'n/a')
GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'n/a')
LEMON_VER=$(lemonade --version 2>/dev/null)

echo -e "${C}═══ SYSTEM ═══${NC}"
echo -e "  Kernel:   ${BOLD}${KERNEL}${NC}"
echo -e "  CPU:      ${CPU}"
echo -e "  GPU:      ${GPU}"
echo -e "  ROCm:     ${ROCM_VER}"
echo -e "  Governor: ${GOV}"
echo -e "  Lemonade: ${LEMON_VER}"
echo ""

# ── Determine which backends to test ──
declare -a BACKEND_LIST
case "$BACKENDS" in
    all)    BACKEND_LIST=(vulkan rocm cpu) ;;
    vr)     BACKEND_LIST=(vulkan rocm) ;;
    vulkan) BACKEND_LIST=(vulkan) ;;
    rocm)   BACKEND_LIST=(rocm) ;;
    cpu)    BACKEND_LIST=(cpu) ;;
    *)      echo "Unknown: $BACKENDS"; usage ;;
esac

# Check which backends are installed
for BE in "${BACKEND_LIST[@]}"; do
    if [ ! -d "/var/lib/lemonade/.cache/lemonade/bin/llamacpp/${BE}" ]; then
        echo -e "  ${Y}⚠${NC} Backend ${BE} not installed — run: lemonade backends install llamacpp:${BE}"
        # Remove from list
        BACKEND_LIST=("${BACKEND_LIST[@]/$BE}")
    else
        echo -e "  ${G}✓${NC} Backend: ${BE}"
    fi
done
echo ""

# ── Check model ──
MODEL=$(curl -s "$MODELS_URL" 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data'][0]['id'] if d.get('data') else '')" 2>/dev/null)
if [ -z "$MODEL" ]; then
    echo -e "${R}ERROR: No model loaded. Run: lemonade run <model>${NC}"
    exit 1
fi
echo -e "  Model:    ${BOLD}${MODEL}${NC}"
echo ""

# ── Benchmark function ──
CURRENT_BACKEND=""
CURRENT_RESULT_FILE=""

bench_run() {
    local NAME="$1"
    local PROMPT_TOKENS="$2"
    local GEN_TOKENS="$3"
    local RUNS="${4:-$REPS}"

    local CHAR_COUNT=$((PROMPT_TOKENS * 4))
    local PROMPT
    PROMPT=$(python3 -c "
text = 'The AMD Ryzen AI MAX+ 395 processor features 16 Zen 5 cores with 32 threads and 128GB unified LPDDR5X memory shared between CPU and integrated Radeon 8060S GPU with RDNA 3.5 architecture. '
prompt = (text * ($CHAR_COUNT // len(text) + 1))[:$CHAR_COUNT]
prompt += ' Based on all of this, summarize the key points.'
import json; print(json.dumps(prompt))
")

    local sum_prompt_tps=0 sum_gen_tps=0 sum_ttft=0

    for ((r=1; r<=RUNS; r++)); do
        local response
        response=$(curl -s "$API_URL" \
            -H "Content-Type: application/json" \
            -d "{
                \"model\": \"${MODEL}\",
                \"messages\": [{\"role\": \"user\", \"content\": ${PROMPT}}],
                \"max_tokens\": ${GEN_TOKENS},
                \"temperature\": 0.1,
                \"chat_template_kwargs\": {\"enable_thinking\": false}
            }" 2>/dev/null)

        local timings
        timings=$(echo "$response" | python3 -c "
import sys, json
d = json.load(sys.stdin)
t = d.get('timings', {})
print(f\"{t.get('prompt_per_second',0)},{t.get('predicted_per_second',0)},{t.get('prompt_ms',0)}\")
" 2>/dev/null)

        IFS=',' read -r p_tps g_tps p_ms <<< "$timings"
        sum_prompt_tps=$(python3 -c "print(${sum_prompt_tps} + ${p_tps})")
        sum_gen_tps=$(python3 -c "print(${sum_gen_tps} + ${g_tps})")
        sum_ttft=$(python3 -c "print(${sum_ttft} + ${p_ms})")
    done

    local avg_p=$(python3 -c "print(round(${sum_prompt_tps}/${RUNS}, 1))")
    local avg_g=$(python3 -c "print(round(${sum_gen_tps}/${RUNS}, 1))")
    local avg_ttft=$(python3 -c "print(round(${sum_ttft}/${RUNS}))")

    echo -e "    ${G}✓${NC} ${NAME} (pp${PROMPT_TOKENS}/tg${GEN_TOKENS}): prompt ${B}${avg_p}${NC} | gen ${B}${avg_g}${NC} | TTFT ${avg_ttft}ms"

    python3 -c "
import json
with open('${CURRENT_RESULT_FILE}') as f: data = json.load(f)
data['benchmarks'].append({
    'name': '${NAME}', 'backend': '${CURRENT_BACKEND}',
    'prompt_tokens_target': ${PROMPT_TOKENS}, 'gen_tokens_target': ${GEN_TOKENS},
    'prompt_tps': ${avg_p}, 'gen_tps': ${avg_g}, 'ttft_ms': ${avg_ttft}, 'runs': ${RUNS}
})
with open('${CURRENT_RESULT_FILE}', 'w') as f: json.dump(data, f, indent=2)
"
}

run_test_suite() {
    echo -e "  ${C}── Prompt Processing (scaling) ──${NC}"
    bench_run "pp64"    64   32  $REPS
    bench_run "pp256"   256  32  $REPS
    bench_run "pp512"   512  32  $REPS
    bench_run "pp1024"  1024 32  $REPS
    bench_run "pp2048"  2048 32  $REPS
    bench_run "pp4096"  4096 32  $REPS

    echo -e "  ${C}── Token Generation (scaling) ──${NC}"
    bench_run "tg32"    64  32   $REPS
    bench_run "tg128"   64  128  $REPS
    bench_run "tg256"   64  256  $REPS
    bench_run "tg512"   64  512  $REPS
    bench_run "tg1024"  64  1024 $REPS
    bench_run "tg2048"  64  2048 2

    echo -e "  ${C}── Mixed Workloads ──${NC}"
    bench_run "mixed_short"   128  256  $REPS
    bench_run "mixed_medium"  512  512  $REPS
    bench_run "mixed_long"    1024 1024 $REPS
    bench_run "mixed_heavy"   2048 2048 2

    echo -e "  ${C}── Long Context ──${NC}"
    bench_run "ctx8k"   8192  32  2
    bench_run "ctx16k"  16384 32  2
}

# ── Main loop — test each backend ──
RESULT_FILE="${OUTPUT_DIR}/toolbox-${KERNEL}-$(date +%Y%m%d-%H%M%S).json"
CURRENT_RESULT_FILE="$RESULT_FILE"

# Init JSON
python3 -c "
import json
data = {
    'kernel': '${KERNEL}', 'timestamp': '${TIMESTAMP}', 'model': '${MODEL}',
    'backends_tested': '${BACKEND_LIST[*]}',
    'methodology': 'adapted from kyuz0/amd-strix-halo-toolboxes',
    'system': {
        'cpu': '${CPU}', 'gpu': '${GPU}', 'rocm': '${ROCM_VER}',
        'governor': '${GOV}', 'lemonade': '${LEMON_VER}'
    },
    'benchmarks': []
}
with open('${RESULT_FILE}', 'w') as f: json.dump(data, f, indent=2)
"

for BACKEND in "${BACKEND_LIST[@]}"; do
    [ -z "$BACKEND" ] && continue
    CURRENT_BACKEND="$BACKEND"

    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
    if [ "$BACKEND" = "vulkan" ]; then
        echo -e "${BOLD}║  BACKEND: VULKAN (h/t u/Look_0ver_There)         ║${NC}"
    elif [ "$BACKEND" = "rocm" ]; then
        echo -e "${BOLD}║  BACKEND: ROCm/HIP (h/t Zhelgadis)              ║${NC}"
    else
        echo -e "${BOLD}║  BACKEND: CPU (AVX-512)                          ║${NC}"
    fi
    echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
    echo ""

    # Unload current model, reload with new backend
    echo -e "  Loading model with ${BACKEND} backend..."
    # Stop current model
    curl -s -X DELETE "$MODELS_URL" 2>/dev/null || true
    sleep 2

    # Reload with specified backend
    lemonade run "$MODEL" --llamacpp "$BACKEND" > /dev/null 2>&1 &
    LOAD_PID=$!

    # Wait for model to be ready
    for i in $(seq 1 60); do
        if curl -s "$MODELS_URL" 2>/dev/null | grep -q '"id"'; then
            break
        fi
        sleep 2
    done

    if ! curl -s "$MODELS_URL" 2>/dev/null | grep -q '"id"'; then
        echo -e "  ${R}✗${NC} Failed to load model with ${BACKEND} — skipping"
        kill $LOAD_PID 2>/dev/null || true
        continue
    fi

    echo -e "  ${G}✓${NC} Model loaded on ${BACKEND}"
    echo ""

    run_test_suite

    echo ""
    rocm-smi --showmeminfo vram 2>/dev/null | grep -E "Used|Total" | head -2
done

# ── Summary comparison ──
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  BACKEND COMPARISON                              ║${NC}"
echo -e "${BOLD}║  \"There can be only one.\" — Highlander            ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""

python3 << 'COMPARE'
import json

with open("RESULT_FILE_PLACEHOLDER") as f:
    data = json.load(f)

# Group by backend
backends = {}
for b in data["benchmarks"]:
    be = b["backend"]
    if be not in backends:
        backends[be] = {}
    backends[be][b["name"]] = b

if len(backends) < 2:
    print("  Only one backend tested — nothing to compare.")
else:
    # Find common tests
    all_tests = set()
    for be in backends.values():
        all_tests.update(be.keys())

    be_names = sorted(backends.keys())

    # Header
    header = f"  {'Test':<16}"
    for be in be_names:
        header += f" | {be:>12}"
    print(header)
    print("  " + "─" * (16 + 15 * len(be_names)))

    # Key tests only
    key_tests = ["pp512", "pp1024", "pp4096", "tg128", "tg512", "tg2048", "mixed_medium", "mixed_heavy", "ctx8k", "ctx16k"]
    for test in key_tests:
        if test not in all_tests:
            continue
        row = f"  {test:<16}"
        gen_values = []
        for be in be_names:
            if test in backends[be]:
                val = backends[be][test]["gen_tps"]
                gen_values.append(val)
                row += f" | {val:>10} t/s"
            else:
                row += f" | {'n/a':>12}"
                gen_values.append(0)
        # Mark winner
        if len(gen_values) > 1 and max(gen_values) > 0:
            winner_idx = gen_values.index(max(gen_values))
            row += f"  ← {be_names[winner_idx]}"
        print(row)

    print()
    print(f"  Model: {data['model']}")
    print(f"  Kernel: {data['kernel']}")

print()
print('  "Designed and built by the architect."')
COMPARE

# Fix the placeholder
sed -i "s|RESULT_FILE_PLACEHOLDER|${RESULT_FILE}|" /dev/stdin 2>/dev/null || true

# Actually run the comparison with the real file
python3 -c "
import json

with open('${RESULT_FILE}') as f:
    data = json.load(f)

backends = {}
for b in data['benchmarks']:
    be = b['backend']
    if be not in backends:
        backends[be] = {}
    backends[be][b['name']] = b

if len(backends) < 2:
    print('  Only one backend tested — nothing to compare.')
else:
    be_names = sorted(backends.keys())
    header = f\"  {'Test':<16}\"
    for be in be_names:
        header += f' | {be:>12}'
    print(header)
    print('  ' + '─' * (16 + 15 * len(be_names)))

    key_tests = ['pp512', 'pp1024', 'pp4096', 'tg128', 'tg512', 'tg2048', 'mixed_medium', 'mixed_heavy', 'ctx8k', 'ctx16k']
    all_tests = set()
    for be in backends.values():
        all_tests.update(be.keys())
    for test in key_tests:
        if test not in all_tests:
            continue
        row = f\"  {test:<16}\"
        gen_values = []
        for be in be_names:
            if test in backends[be]:
                val = backends[be][test]['gen_tps']
                gen_values.append(val)
                row += f' | {val:>10} t/s'
            else:
                row += f\" | {'n/a':>12}\"
                gen_values.append(0)
        if len(gen_values) > 1 and max(gen_values) > 0:
            winner_idx = gen_values.index(max(gen_values))
            row += f'  <- {be_names[winner_idx]}'
        print(row)
    print()
    print(f\"  Model: {data['model']}\")
    print(f\"  Kernel: {data['kernel']}\")
print()
print('  Designed and built by the architect.')
"

echo ""
echo -e "  Results: ${RESULT_FILE}"
echo ""

# ── Rotate old results (5 days) ──
CUTOFF=$(date -d "5 days ago" +%Y%m%d 2>/dev/null || echo "")
if [ -n "$CUTOFF" ]; then
    for OLD in "${OUTPUT_DIR}"/toolbox-*.json; do
        [ -f "$OLD" ] || continue
        FILE_DATE=$(basename "$OLD" | grep -oP '\d{8}' | head -1)
        if [ -n "$FILE_DATE" ] && [ "$FILE_DATE" -lt "$CUTOFF" ]; then
            rm -f "$OLD"
        fi
    done
fi
echo ""
