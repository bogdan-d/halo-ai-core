#!/bin/bash
# ============================================================
# bench-toolbox — kyuz0-style benchmark adapted for Lemonade
# Designed and built by the architect
#
# "Adapt. Improvise. Overcome." — Bear Grylls
#
# Adapted from kyuz0/amd-strix-halo-toolboxes (150 benchmarks)
# Same methodology: multiple prompt lengths, gen lengths, reps
# Our backend: Lemonade Vulkan (h/t u/Look_0ver_There)
#
# Credit: kyuz0 for the benchmark framework
# https://github.com/kyuz0/amd-strix-halo-toolboxes
# ============================================================
set -euo pipefail

API_URL="http://localhost:13305/v1/chat/completions"
MODELS_URL="http://localhost:13305/v1/models"
KERNEL=$(uname -r)
TIMESTAMP=$(date -Iseconds)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/bench-results"
RESULT_FILE="${OUTPUT_DIR}/toolbox-${KERNEL}-$(date +%Y%m%d-%H%M%S).json"
REPS=3
mkdir -p "$OUTPUT_DIR"

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; C='\033[0;36m'; R='\033[0;31m'; NC='\033[0m'; BOLD='\033[1m'

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  bench-toolbox — kyuz0-style for Lemonade        ║${NC}"
echo -e "${BOLD}║  \"Adapt. Improvise. Overcome.\" — Bear Grylls     ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ── System info ──
echo -e "${C}═══ SYSTEM ═══${NC}"
CPU=$(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
GPU=$(rocm-smi --showproductname 2>/dev/null | grep 'Card Series' | head -1 | awk -F: '{print $NF}' | xargs)
ROCM=$(cat /opt/rocm/.info/version 2>/dev/null || echo 'n/a')
GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'n/a')
LEMON_VER=$(lemonade --version 2>/dev/null)
echo -e "  Kernel:   ${BOLD}${KERNEL}${NC}"
echo -e "  CPU:      ${CPU}"
echo -e "  GPU:      ${GPU}"
echo -e "  ROCm:     ${ROCM}"
echo -e "  Governor: ${GOV}"
echo -e "  Lemonade: ${LEMON_VER}"
echo -e "  Backend:  Vulkan (h/t u/Look_0ver_There)"
echo ""

# ── Check model ──
MODEL=$(curl -s "$MODELS_URL" 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data'][0]['id'] if d.get('data') else '')" 2>/dev/null)
if [ -z "$MODEL" ]; then
    echo -e "${R}ERROR: No model loaded${NC}"
    exit 1
fi
echo -e "  Model:    ${BOLD}${MODEL}${NC}"
echo ""

# Init JSON
python3 -c "
import json
data = {
    'kernel': '${KERNEL}', 'timestamp': '${TIMESTAMP}', 'model': '${MODEL}',
    'backend': 'lemonade-vulkan',
    'methodology': 'adapted from kyuz0/amd-strix-halo-toolboxes',
    'system': {
        'cpu': '${CPU}', 'gpu': '${GPU}', 'rocm': '${ROCM}',
        'governor': '${GOV}', 'lemonade': '${LEMON_VER}'
    },
    'benchmarks': []
}
with open('${RESULT_FILE}', 'w') as f: json.dump(data, f, indent=2)
"

# ── Benchmark function ──
# Matches kyuz0 methodology: specific prompt token counts, gen token counts
bench_run() {
    local NAME="$1"
    local PROMPT_TOKENS="$2"   # target prompt length
    local GEN_TOKENS="$3"      # target generation length
    local RUNS="${4:-$REPS}"

    # Build a prompt of approximate token length
    # ~4 chars per token, fill with technical text
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
u = d.get('usage', {})
print(f\"{t.get('prompt_per_second',0)},{t.get('predicted_per_second',0)},{t.get('prompt_ms',0)},{u.get('prompt_tokens',0)},{u.get('completion_tokens',0)}\")
" 2>/dev/null)

        IFS=',' read -r p_tps g_tps p_ms actual_p actual_g <<< "$timings"

        sum_prompt_tps=$(python3 -c "print(${sum_prompt_tps} + ${p_tps})")
        sum_gen_tps=$(python3 -c "print(${sum_gen_tps} + ${g_tps})")
        sum_ttft=$(python3 -c "print(${sum_ttft} + ${p_ms})")
    done

    local avg_p=$(python3 -c "print(round(${sum_prompt_tps}/${RUNS}, 1))")
    local avg_g=$(python3 -c "print(round(${sum_gen_tps}/${RUNS}, 1))")
    local avg_ttft=$(python3 -c "print(round(${sum_ttft}/${RUNS}))")

    echo -e "  ${G}✓${NC} ${NAME} (pp${PROMPT_TOKENS}/tg${GEN_TOKENS}): prompt ${B}${avg_p}${NC} t/s | gen ${B}${avg_g}${NC} t/s | TTFT ${avg_ttft}ms"

    # Append to JSON
    python3 -c "
import json
with open('${RESULT_FILE}') as f: data = json.load(f)
data['benchmarks'].append({
    'name': '${NAME}',
    'prompt_tokens_target': ${PROMPT_TOKENS},
    'gen_tokens_target': ${GEN_TOKENS},
    'prompt_tps': ${avg_p}, 'gen_tps': ${avg_g},
    'ttft_ms': ${avg_ttft}, 'runs': ${RUNS}
})
with open('${RESULT_FILE}', 'w') as f: json.dump(data, f, indent=2)
"
}

# ── Run kyuz0-style benchmarks ──
# Matches their prompt/gen token configurations

echo -e "${C}═══ PROMPT PROCESSING (scaling) ═══${NC}"
echo -e "  ${B}\"How fast can you read?\"${NC}"
bench_run "pp64"    64   32  $REPS
bench_run "pp256"   256  32  $REPS
bench_run "pp512"   512  32  $REPS
bench_run "pp1024"  1024 32  $REPS
bench_run "pp2048"  2048 32  $REPS
bench_run "pp4096"  4096 32  $REPS

echo ""
echo -e "${C}═══ TOKEN GENERATION (scaling) ═══${NC}"
echo -e "  ${B}\"How fast can you talk?\"${NC}"
bench_run "tg32"    64  32   $REPS
bench_run "tg128"   64  128  $REPS
bench_run "tg256"   64  256  $REPS
bench_run "tg512"   64  512  $REPS
bench_run "tg1024"  64  1024 $REPS
bench_run "tg2048"  64  2048 2

echo ""
echo -e "${C}═══ MIXED WORKLOADS ═══${NC}"
echo -e "  ${B}\"The real deal.\"${NC}"
bench_run "mixed_short"   128  256  $REPS
bench_run "mixed_medium"  512  512  $REPS
bench_run "mixed_long"    1024 1024 $REPS
bench_run "mixed_heavy"   2048 2048 2

echo ""
echo -e "${C}═══ LONG CONTEXT (32K stress) ═══${NC}"
echo -e "  ${B}\"You can't handle the truth!\"${NC}"
bench_run "ctx8k"   8192  32  2
bench_run "ctx16k"  16384 32  2

# ── GPU Memory ──
echo ""
echo -e "${C}═══ GPU MEMORY ═══${NC}"
rocm-smi --showmeminfo vram 2>/dev/null | grep -E "Used|Total" | head -4

# ── Summary ──
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  Toolbox Benchmark Complete                      ║${NC}"
echo -e "${BOLD}║  \"Hasta la vista, baby.\" — T-800                 ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Results: ${RESULT_FILE}"
echo ""

# Summary table
python3 -c "
import json
with open('${RESULT_FILE}') as f: data = json.load(f)
print('  ┌──────────────────┬────────┬────────┬────────────┬───────────┬─────────┐')
print('  │ Test             │  pp    │  tg    │ Prompt t/s │ Gen t/s   │ TTFT ms │')
print('  ├──────────────────┼────────┼────────┼────────────┼───────────┼─────────┤')
for b in data['benchmarks']:
    print(f\"  │ {b['name']:<16} │ {b['prompt_tokens_target']:>6} │ {b['gen_tokens_target']:>6} │ {b['prompt_tps']:>10} │ {b['gen_tps']:>9} │ {b['ttft_ms']:>7} │\")
print('  └──────────────────┴────────┴────────┴────────────┴───────────┴─────────┘')
print()
print(f'  Backend: Lemonade Vulkan (h/t u/Look_0ver_There)')
print(f'  Methodology: adapted from kyuz0/amd-strix-halo-toolboxes')
print(f'  Model: {data[\"model\"]}')
print(f'  Kernel: {data[\"kernel\"]}')
"
echo ""
echo -e "  ${B}\"Designed and built by the architect.\"${NC}"

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
