#!/bin/bash
# ============================================================
# halo-bench — LLM Benchmark Suite for Halo AI Core
# Designed and built by the architect
#
# "Faster, faster, until the thrill of speed overcomes
#  the fear of death." — Hunter S. Thompson
#
# Comprehensive benchmarks: prompt throughput, generation speed,
# context scaling, reasoning, code gen, multi-turn, concurrency
# ============================================================
set -euo pipefail

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Defaults
LEMONADE_HOST="${LEMONADE_HOST:-localhost}"
LEMONADE_PORT="${LEMONADE_PORT:-13305}"
API_URL="http://${LEMONADE_HOST}:${LEMONADE_PORT}/v1/chat/completions"
MODELS_URL="http://${LEMONADE_HOST}:${LEMONADE_PORT}/v1/models"
RUNS=3          # repeat each benchmark N times for stability
OUTPUT_DIR="${HALO_BENCH_OUTPUT:-${SCRIPT_DIR}/bench-results}"
JSON_LOG=""
CSV_LOG=""
CAST_FILE=""
MODEL_FILTER=""
SKIP_LOAD=false
QUICK=false
VERBOSE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ============================================================
# CLI
# ============================================================
usage() {
    cat <<EOF
${BOLD}halo-bench v${VERSION}${NC} — LLM Benchmark Suite for Halo AI Core

${BOLD}Usage:${NC}
  ./halo-bench.sh [OPTIONS]

${BOLD}Options:${NC}
  -m, --model MODEL     Benchmark only this model (default: all downloaded)
  -r, --runs N          Repeat each test N times (default: 3)
  -q, --quick           Quick mode: 1 run, fewer tests
  -o, --output DIR      Output directory (default: bench-results/)
  --record              Record with asciinema
  --skip-load           Don't switch models (benchmark whatever is loaded)
  --host HOST           Lemonade host (default: localhost)
  --port PORT           Lemonade port (default: 13305)
  -v, --verbose         Show raw API responses
  -h, --help            Show this help

${BOLD}Examples:${NC}
  ./halo-bench.sh                              # Full suite, all models
  ./halo-bench.sh -m Qwen3.5-35B-A3B-GGUF     # Single model
  ./halo-bench.sh -q                           # Quick run
  ./halo-bench.sh --record                     # With asciinema
  ./halo-bench.sh -r 5 -v                      # 5 runs, verbose

${BOLD}Output:${NC}
  bench-results/YYYY-MM-DD_HHMMSS/
    summary.txt        Human-readable summary
    results.json       Machine-readable full results
    results.csv        Spreadsheet-friendly
    bench.cast         Asciinema recording (if --record)
EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--model)    MODEL_FILTER="$2"; shift 2 ;;
        -r|--runs)     RUNS="$2"; shift 2 ;;
        -q|--quick)    QUICK=true; RUNS=1; shift ;;
        -o|--output)   OUTPUT_DIR="$2"; shift 2 ;;
        --record)      CAST_FILE="bench.cast"; shift ;;
        --skip-load)   SKIP_LOAD=true; shift ;;
        --host)        LEMONADE_HOST="$2"; API_URL="http://${LEMONADE_HOST}:${LEMONADE_PORT}/v1/chat/completions"; shift 2 ;;
        --port)        LEMONADE_PORT="$2"; API_URL="http://${LEMONADE_HOST}:${LEMONADE_PORT}/v1/chat/completions"; shift 2 ;;
        -v|--verbose)  VERBOSE=true; shift ;;
        -h|--help)     usage ;;
        *)             echo "Unknown option: $1"; usage ;;
    esac
done

# ============================================================
# UTILITIES
# ============================================================
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

header() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

subheader() {
    echo ""
    echo -e "${BLUE}  ── $1 ──${NC}"
}

result_line() {
    local label="$1"
    local value="$2"
    local unit="${3:-}"
    printf "  ${GREEN}%-35s${NC} %10s %s\n" "$label" "$value" "$unit"
}

warn_line() {
    printf "  ${YELLOW}%-35s${NC} %10s %s\n" "$1" "$2" "${3:-}"
}

err_line() {
    printf "  ${RED}%-35s${NC} %10s %s\n" "$1" "$2" "${3:-}"
}

# JSON helper — append to results
json_append() {
    local key="$1"
    local value="$2"
    echo "    \"${key}\": ${value}," >> "$JSON_LOG"
}

csv_append() {
    echo "$1" >> "$CSV_LOG"
}

# ============================================================
# API CALL WITH TIMING
# ============================================================
api_call() {
    local payload="$1"
    local timeout="${2:-120}"

    local response
    response=$(curl -s --max-time "$timeout" -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>/dev/null)

    if [[ -z "$response" ]]; then
        echo '{"error":"timeout or no response"}'
        return 1
    fi

    if $VERBOSE; then
        echo "$response" | python3 -m json.tool 2>/dev/null >&2 || true
    fi

    echo "$response"
}

# Extract timings from response
extract_timings() {
    local response="$1"
    LC_ALL=C python3 -c "
import sys, json
try:
    r = json.loads(sys.argv[1])
    if 'error' in r:
        print('ERROR|0|0|0|0|0|0|0')
        sys.exit(0)
    t = r.get('timings', {})
    u = r.get('usage', {})
    print(f\"{t.get('prompt_per_second',0):.2f}|{t.get('predicted_per_second',0):.2f}|{t.get('prompt_n',0)}|{t.get('predicted_n',0)}|{t.get('prompt_ms',0):.2f}|{t.get('predicted_ms',0):.2f}|{u.get('prompt_tokens',0)}|{u.get('completion_tokens',0)}\")
except Exception as e:
    print(f'ERROR|0|0|0|0|0|0|0')
" "$response"
}

# Run a benchmark N times and compute stats
run_bench() {
    local name="$1"
    local payload="$2"
    local timeout="${3:-120}"
    local runs="${4:-$RUNS}"

    local pp_speeds=()
    local gen_speeds=()
    local pp_tokens_arr=()
    local gen_tokens_arr=()
    local ttfts=()
    local total_times=()
    local failures=0

    for ((i=1; i<=runs; i++)); do
        local result
        result=$(api_call "$payload" "$timeout")
        local timings
        timings=$(extract_timings "$result")

        IFS='|' read -r pp_speed gen_speed pp_tokens gen_tokens pp_ms gen_ms prompt_usage completion_usage <<< "$timings"

        # Locale fix: convert any decimal commas to dots (e.g. French locale)
        pp_speed="${pp_speed/,/.}"
        gen_speed="${gen_speed/,/.}"
        pp_ms="${pp_ms/,/.}"
        gen_ms="${gen_ms/,/.}"

        if [[ "$pp_speed" == "ERROR" ]]; then
            failures=$((failures + 1))
            continue
        fi

        pp_speeds+=("$pp_speed")
        gen_speeds+=("$gen_speed")
        pp_tokens_arr+=("$pp_tokens")
        gen_tokens_arr+=("$gen_tokens")
        ttfts+=("$pp_ms")
        total_times+=("$(LC_ALL=C python3 -c "print(f'{$pp_ms + $gen_ms:.2f}')")")

        if [[ $runs -gt 1 ]]; then
            printf "\r  ${DIM}Run %d/%d: pp=%.1f tok/s gen=%.1f tok/s${NC}    " "$i" "$runs" "$pp_speed" "$gen_speed"
        fi
    done

    if [[ $runs -gt 1 ]]; then
        printf "\r%80s\r" " "
    fi

    if [[ ${#gen_speeds[@]} -eq 0 ]]; then
        err_line "$name" "FAILED" "(all $failures runs failed)"
        csv_append "${CURRENT_MODEL},${name},FAIL,0,0,0,0,0,0,0,0"
        return 1
    fi

    # Compute averages and stddev
    local stats
    stats=$(LC_ALL=C python3 -c "
import statistics
pp = [$(IFS=,; echo "${pp_speeds[*]}")]
gen = [$(IFS=,; echo "${gen_speeds[*]}")]
pp_tok = [$(IFS=,; echo "${pp_tokens_arr[*]}")]
gen_tok = [$(IFS=,; echo "${gen_tokens_arr[*]}")]
ttft = [$(IFS=,; echo "${ttfts[*]}")]
total = [$(IFS=,; echo "${total_times[*]}")]

pp_avg = statistics.mean(pp)
gen_avg = statistics.mean(gen)
pp_std = statistics.stdev(pp) if len(pp) > 1 else 0
gen_std = statistics.stdev(gen) if len(gen) > 1 else 0
pp_tok_avg = statistics.mean(pp_tok)
gen_tok_avg = statistics.mean(gen_tok)
ttft_avg = statistics.mean(ttft)
total_avg = statistics.mean(total)

print(f'{pp_avg:.1f}|{gen_avg:.1f}|{pp_std:.1f}|{gen_std:.1f}|{pp_tok_avg:.0f}|{gen_tok_avg:.0f}|{ttft_avg:.0f}|{total_avg:.0f}')
")

    IFS='|' read -r pp_avg gen_avg pp_std gen_std pp_tok_avg gen_tok_avg ttft_avg total_avg <<< "$stats"

    # Display
    local std_note=""
    if [[ $runs -gt 1 ]]; then
        std_note=" (+-${gen_std})"
    fi
    result_line "$name" "${gen_avg}" "tok/s${std_note}"
    printf "  ${DIM}%-35s %10s tok/s | prompt: %s tok | gen: %s tok | TTFT: %sms${NC}\n" \
        "" "${pp_avg}" "${pp_tok_avg}" "${gen_tok_avg}" "${ttft_avg}"

    # CSV
    csv_append "${CURRENT_MODEL},${name},OK,${pp_avg},${gen_avg},${pp_std},${gen_std},${pp_tok_avg},${gen_tok_avg},${ttft_avg},${total_avg}"

    # JSON
    cat >> "$JSON_LOG" <<JSONBLOCK
    {
      "test": "${name}",
      "model": "${CURRENT_MODEL}",
      "runs": ${runs},
      "failures": ${failures},
      "prompt_tok_s_avg": ${pp_avg},
      "prompt_tok_s_std": ${pp_std},
      "gen_tok_s_avg": ${gen_avg},
      "gen_tok_s_std": ${gen_std},
      "prompt_tokens_avg": ${pp_tok_avg},
      "gen_tokens_avg": ${gen_tok_avg},
      "ttft_ms_avg": ${ttft_avg},
      "total_ms_avg": ${total_avg}
    },
JSONBLOCK
}

# ============================================================
# HARDWARE INFO
# ============================================================
collect_hw_info() {
    header "Hardware Profile"

    local cpu
    cpu=$(grep "model name" /proc/cpuinfo | head -1 | sed 's/model name.*: //')
    local cores
    cores=$(nproc)
    local mem_total
    mem_total=$(free -h | awk '/^Mem:/{print $2}')
    local mem_used
    mem_used=$(free -h | awk '/^Mem:/{print $3}')
    local gpu
    gpu=$(/opt/rocm/bin/rocminfo 2>/dev/null | grep "Marketing Name" | grep -v CPU | head -1 | sed 's/.*: *//' || echo "unknown")
    local rocm_ver
    rocm_ver=$(cat /opt/rocm/.info/version 2>/dev/null || echo "unknown")
    local kernel
    kernel=$(uname -r)
    local lemonade_ver
    lemonade_ver=$(lemonade --version 2>/dev/null || echo "unknown")
    local llama_ver
    llama_ver=$(/usr/local/bin/llama-server --version 2>&1 | grep version | head -1 || echo "unknown")

    result_line "CPU" "$cpu"
    result_line "Cores" "$cores"
    result_line "Memory" "${mem_used} / ${mem_total}"
    result_line "GPU" "$gpu"
    result_line "ROCm" "$rocm_ver"
    result_line "Kernel" "$kernel"
    result_line "Lemonade" "$lemonade_ver"
    result_line "llama.cpp" "$llama_ver"
    echo ""

    # Write to JSON
    cat >> "$JSON_LOG" <<HWJSON
  "hardware": {
    "cpu": "$cpu",
    "cores": $cores,
    "memory_total": "$mem_total",
    "gpu": "$gpu",
    "rocm": "$rocm_ver",
    "kernel": "$kernel",
    "lemonade": "$lemonade_ver",
    "llama_cpp": "$llama_ver"
  },
HWJSON

    # Memory bandwidth test (quick dd)
    subheader "Memory Bandwidth (quick estimate)"
    local bw
    bw=$(dd if=/dev/zero of=/dev/null bs=1G count=4 2>&1 | grep -oP '[\d.]+ [GM]B/s' || echo "unknown")
    result_line "Sequential throughput" "$bw"
}

# ============================================================
# BENCHMARK SUITES
# ============================================================

# --- Prompt Processing Scaling ---
bench_prompt_scaling() {
    header "Prompt Processing Scaling"
    echo -e "  ${DIM}How fast does it chew through input tokens?${NC}"

    # Generate payloads of increasing size
    local sizes=(16 64 256 1024 2048 4096)
    if $QUICK; then
        sizes=(16 256 1024)
    fi

    for size in "${sizes[@]}"; do
        local filler
        filler=$(python3 -c "print(' '.join(['word'] * $size))")
        local payload
        payload=$(python3 -c "
import json
msg = json.dumps({
    'model': '${CURRENT_MODEL}',
    'messages': [{'role': 'user', 'content': 'Summarize: ${filler}'}],
    'max_tokens': 10,
    'stream': False
})
print(msg)
")
        run_bench "Prompt ~${size} tokens" "$payload" 60
    done
}

# --- Generation Speed ---
bench_generation_speed() {
    header "Generation Speed"
    echo -e "  ${DIM}Sustained output throughput at different lengths${NC}"

    local sizes=(50 100 250 500 1000)
    if $QUICK; then
        sizes=(50 250 500)
    fi

    for size in "${sizes[@]}"; do
        local payload="{\"model\":\"${CURRENT_MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":\"Write exactly ${size} words about the history of computing. Be detailed.\"}],\"max_tokens\":${size},\"stream\":false}"
        local timeout=$((size / 10 + 30))
        run_bench "Generate ${size} tokens" "$payload" "$timeout"
    done
}

# --- Context Window Stress ---
bench_context_stress() {
    header "Context Window Stress"
    echo -e "  ${DIM}Performance under increasing context load${NC}"

    local sizes=(1024 4096 8192 16384)
    if $QUICK; then
        sizes=(1024 4096 8192)
    fi

    for size in "${sizes[@]}"; do
        local filler
        filler=$(python3 -c "
import json
# Generate realistic-looking context
sentences = [
    'The transformer architecture revolutionized natural language processing.',
    'Self-attention mechanisms allow models to weigh the importance of different input tokens.',
    'GPU acceleration is critical for inference performance in large language models.',
    'Quantization reduces model size while maintaining acceptable quality.',
    'The mixture of experts architecture activates only a subset of parameters per token.',
]
text = ' '.join([sentences[i % len(sentences)] for i in range($size // 12)])
print(json.dumps(text))
")
        local payload="{\"model\":\"${CURRENT_MODEL}\",\"messages\":[{\"role\":\"system\",\"content\":\"You are a concise summarizer.\"},{\"role\":\"user\",\"content\":${filler}}],\"max_tokens\":100,\"stream\":false}"
        local timeout=$((size / 100 + 60))
        run_bench "Context ~${size} tokens" "$payload" "$timeout"
    done
}

# --- Reasoning / Thinking ---
bench_reasoning() {
    header "Reasoning & Thinking"
    echo -e "  ${DIM}Tasks that trigger extended chain-of-thought${NC}"

    local -a tests=(
        "Math|Solve step by step: If a train leaves station A at 60 km/h and another leaves station B (300 km away) at 80 km/h heading toward each other, when and where do they meet? Show all work."
        "Logic|Three people (A, B, C) each have a different pet (cat, dog, fish). A does not have a cat. B does not have a dog. C does not have a fish. B has a cat. Who has what pet? Explain your reasoning step by step."
        "Code reasoning|What is the output of this Python code and why?\n\ndef f(n, memo={}):\n    if n in memo: return memo[n]\n    if n <= 1: return n\n    memo[n] = f(n-1) + f(n-2)\n    return memo[n]\n\nprint([f(i) for i in range(10)])\n\nExplain the mutable default argument behavior."
        "Analysis|Compare and contrast TCP and UDP. When would you use each? Give specific examples with port numbers and real-world applications. Be thorough."
    )

    if $QUICK; then
        tests=("${tests[0]}" "${tests[2]}")
    fi

    for test_entry in "${tests[@]}"; do
        IFS='|' read -r test_name test_prompt <<< "$test_entry"
        local escaped_prompt
        escaped_prompt=$(python3 -c "import json; print(json.dumps($( python3 -c "import json; print(json.dumps('$test_prompt'))" )))" 2>/dev/null || python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$test_prompt")
        local payload="{\"model\":\"${CURRENT_MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":${escaped_prompt}}],\"max_tokens\":500,\"stream\":false}"
        run_bench "Reasoning: ${test_name}" "$payload" 120
    done
}

# --- Code Generation ---
bench_code_gen() {
    header "Code Generation"
    echo -e "  ${DIM}Structured code output across languages${NC}"

    local -a tests=(
        'Python async|Write a Python async web server using aiohttp with health check, file upload, and WebSocket endpoints. Include error handling and type hints.'
        'Rust systems|Write a Rust program that reads a large CSV file concurrently using rayon, computes column statistics (mean, median, stddev), and outputs results as JSON.'
        'Bash scripting|Write a bash script that monitors system health: CPU temp, GPU utilization, memory pressure, disk I/O, and network throughput. Output as a formatted table every 5 seconds.'
        'SQL complex|Write a PostgreSQL query that finds the top 10 customers by lifetime value, their most purchased product category, average order frequency, and churn risk score. Use CTEs and window functions.'
    )

    if $QUICK; then
        tests=("${tests[0]}" "${tests[2]}")
    fi

    for test_entry in "${tests[@]}"; do
        IFS='|' read -r test_name test_prompt <<< "$test_entry"
        local escaped_prompt
        escaped_prompt=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$test_prompt")
        local payload="{\"model\":\"${CURRENT_MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":${escaped_prompt}}],\"max_tokens\":800,\"stream\":false}"
        run_bench "Code: ${test_name}" "$payload" 120
    done
}

# --- Multi-Turn Conversation ---
bench_multi_turn() {
    header "Multi-Turn Conversation"
    echo -e "  ${DIM}Simulated conversation with growing context${NC}"

    local messages='[{"role":"user","content":"What is a neural network?"}]'
    local payload="{\"model\":\"${CURRENT_MODEL}\",\"messages\":${messages},\"max_tokens\":200,\"stream\":false}"
    run_bench "Turn 1 (cold start)" "$payload" 60 1

    # Build up turns
    local turns=(
        '{"role":"assistant","content":"A neural network is a computational model inspired by the human brain. It consists of layers of interconnected nodes (neurons) that process information. Each connection has a weight that adjusts during training."}'
        '{"role":"user","content":"How does backpropagation work in training?"}'
        '{"role":"assistant","content":"Backpropagation computes gradients of the loss function with respect to each weight by applying the chain rule. It propagates error signals backward through the network, allowing gradient descent to update weights."}'
        '{"role":"user","content":"What are transformers and how do they differ from RNNs?"}'
        '{"role":"assistant","content":"Transformers use self-attention mechanisms to process all input tokens in parallel, unlike RNNs which process sequentially. This parallelism enables faster training and better handling of long-range dependencies."}'
        '{"role":"user","content":"Explain the attention mechanism in detail with the mathematical formulation."}'
    )

    local msg_array='[{"role":"user","content":"What is a neural network?"}'
    local turn_num=2
    for turn in "${turns[@]}"; do
        msg_array="${msg_array},${turn}"
        if [[ "$turn" == *'"role":"user"'* ]]; then
            local payload="{\"model\":\"${CURRENT_MODEL}\",\"messages\":[${msg_array}],\"max_tokens\":300,\"stream\":false}"
            run_bench "Turn ${turn_num} (~${turn_num}k context)" "$payload" 90 1
            turn_num=$((turn_num + 1))
        fi
    done
}

# --- Instruction Following ---
bench_instruction() {
    header "Instruction Following"
    echo -e "  ${DIM}Precise format compliance and constraint adherence${NC}"

    local -a tests=(
        'JSON output|Return a JSON object with exactly these fields: name (string), age (integer), skills (array of 3 strings), address (nested object with street, city, country). Do not include any text outside the JSON.'
        'Constrained format|List exactly 5 benefits of open-source software. Each must be exactly one sentence. Number them 1-5. Do not add introductions or conclusions.'
        'System prompt adherence|You must respond ONLY in haiku format (5-7-5 syllables). What is machine learning?'
    )

    if $QUICK; then
        tests=("${tests[0]}")
    fi

    for test_entry in "${tests[@]}"; do
        IFS='|' read -r test_name test_prompt <<< "$test_entry"
        local escaped_prompt
        escaped_prompt=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$test_prompt")
        local payload="{\"model\":\"${CURRENT_MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":${escaped_prompt}}],\"max_tokens\":300,\"stream\":false}"
        run_bench "Instruct: ${test_name}" "$payload" 60
    done
}

# --- Concurrent Requests ---
bench_concurrency() {
    header "Concurrency"
    echo -e "  ${DIM}Parallel request handling (if slots available)${NC}"

    local payload="{\"model\":\"${CURRENT_MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":\"What is 2+2?\"}],\"max_tokens\":20,\"stream\":false}"

    # Baseline: single request
    subheader "Baseline (sequential)"
    local start_time
    start_time=$(date +%s%N)
    for i in {1..5}; do
        curl -s --max-time 30 -X POST "$API_URL" \
            -H "Content-Type: application/json" \
            -d "$payload" > /dev/null 2>&1
    done
    local end_time
    end_time=$(date +%s%N)
    local seq_ms=$(( (end_time - start_time) / 1000000 ))
    result_line "5 sequential requests" "${seq_ms}" "ms"

    # Concurrent: 5 parallel
    subheader "Concurrent (5 parallel)"
    start_time=$(date +%s%N)
    for i in {1..5}; do
        curl -s --max-time 30 -X POST "$API_URL" \
            -H "Content-Type: application/json" \
            -d "$payload" > /dev/null 2>&1 &
    done
    wait
    end_time=$(date +%s%N)
    local par_ms=$(( (end_time - start_time) / 1000000 ))
    result_line "5 parallel requests" "${par_ms}" "ms"

    local speedup
    speedup=$(python3 -c "print(f'{$seq_ms / max($par_ms, 1):.2f}')")
    result_line "Speedup" "${speedup}x"

    csv_append "${CURRENT_MODEL},Concurrency: 5 sequential,OK,0,0,0,0,0,0,0,${seq_ms}"
    csv_append "${CURRENT_MODEL},Concurrency: 5 parallel,OK,0,0,0,0,0,0,0,${par_ms}"
}

# --- Memory Usage ---
bench_memory() {
    header "Memory Usage"
    echo -e "  ${DIM}VRAM/RAM consumption during inference${NC}"

    local mem_before
    mem_before=$(free -m | awk '/^Mem:/{print $3}')

    # Trigger a large generation to stress memory
    local payload="{\"model\":\"${CURRENT_MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":\"Write an extremely detailed 2000-word essay about the complete history of artificial intelligence from the 1950s to today.\"}],\"max_tokens\":1500,\"stream\":false}"
    curl -s --max-time 120 -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d "$payload" > /dev/null 2>&1

    local mem_after
    mem_after=$(free -m | awk '/^Mem:/{print $3}')
    local mem_delta=$((mem_after - mem_before))

    result_line "RAM before" "${mem_before}" "MB"
    result_line "RAM after" "${mem_after}" "MB"
    result_line "RAM delta" "${mem_delta}" "MB"

    # GPU memory via rocm-smi if available
    if command -v rocm-smi &>/dev/null; then
        local gpu_mem
        gpu_mem=$(rocm-smi --showmeminfo vram 2>/dev/null | grep "Used" | awk '{print $NF}' || echo "unknown")
        result_line "GPU VRAM used" "$gpu_mem"
    fi

    # Process memory
    local lemond_pid
    lemond_pid=$(pgrep -f lemond | head -1 || echo "")
    if [[ -n "$lemond_pid" ]]; then
        local proc_rss
        proc_rss=$(ps -o rss= -p "$lemond_pid" 2>/dev/null | awk '{print int($1/1024)}')
        result_line "lemond RSS" "${proc_rss}" "MB"
    fi

    local llama_pid
    llama_pid=$(pgrep -f llama-server | head -1 || echo "")
    if [[ -n "$llama_pid" ]]; then
        local proc_rss
        proc_rss=$(ps -o rss= -p "$llama_pid" 2>/dev/null | awk '{print int($1/1024)}')
        result_line "llama-server RSS" "${proc_rss}" "MB"
    fi
}

# ============================================================
# MODEL LOADING
# ============================================================
load_model() {
    local model="$1"

    subheader "Loading model: ${model}"

    # Check if already loaded
    local loaded
    loaded=$(lemonade --port "$LEMONADE_PORT" status 2>/dev/null | grep "$model" || true)
    if [[ -n "$loaded" ]]; then
        result_line "Already loaded" "$model"
        return 0
    fi

    # Unload current, load new
    lemonade --port "$LEMONADE_PORT" unload --all >> /dev/null 2>&1 || true
    sleep 2

    local start_time
    start_time=$(date +%s)
    lemonade --port "$LEMONADE_PORT" load -m "$model" >> /dev/null 2>&1

    # Wait for model to be ready
    local attempts=0
    while [[ $attempts -lt 60 ]]; do
        local status
        status=$(curl -s --max-time 5 "$MODELS_URL" 2>/dev/null || echo "")
        if [[ -n "$status" && "$status" != *"error"* ]]; then
            break
        fi
        sleep 2
        attempts=$((attempts + 1))
    done

    local end_time
    end_time=$(date +%s)
    local load_time=$((end_time - start_time))
    result_line "Model loaded in" "${load_time}" "seconds"
}

# ============================================================
# SUMMARY GENERATOR
# ============================================================
generate_summary() {
    local summary_file="${RUN_DIR}/summary.txt"

    {
        echo "═══════════════════════════════════════════════════════════════"
        echo "  Halo AI Core — LLM Benchmark Results"
        echo "  Generated: $(timestamp)"
        echo "  halo-bench v${VERSION}"
        echo "═══════════════════════════════════════════════════════════════"
        echo ""
        echo "Hardware:"
        grep "model name" /proc/cpuinfo | head -1 | sed 's/model name.*: /  CPU: /'
        echo "  Cores: $(nproc)"
        echo "  Memory: $(free -h | awk '/^Mem:/{print $2}')"
        echo "  GPU: $(/opt/rocm/bin/rocminfo 2>/dev/null | grep 'Marketing Name' | grep -v CPU | head -1 | sed 's/.*: *//')"
        echo ""
        echo "Models benchmarked:"
        grep -v "^model," "$CSV_LOG" | cut -d',' -f1 | sort -u | sed 's/^/  - /'
        echo ""
        echo "Configuration:"
        echo "  Runs per test: ${RUNS}"
        echo "  Quick mode: ${QUICK}"
        echo ""
        echo "Results (see results.csv for full data):"
        echo ""

        # Parse CSV into table
        printf "  %-40s %-15s %12s %12s\n" "Test" "Model" "Gen tok/s" "Prompt tok/s"
        printf "  %-40s %-15s %12s %12s\n" "────────────────────────────────────────" "───────────────" "────────────" "────────────"
        tail -n +2 "$CSV_LOG" | while IFS=',' read -r model test status pp_avg gen_avg pp_std gen_std pp_tok gen_tok ttft total; do
            if [[ "$status" == "OK" ]]; then
                local short_model
                short_model=$(echo "$model" | sed 's/-GGUF//' | cut -c1-15)
                printf "  %-40s %-15s %12s %12s\n" "$test" "$short_model" "$gen_avg" "$pp_avg"
            fi
        done

        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "  Designed and built by the architect"
        echo "═══════════════════════════════════════════════════════════════"
    } > "$summary_file"

    cat "$summary_file"
}

# ============================================================
# MAIN
# ============================================================
main() {
    # Setup output dir
    local run_timestamp
    run_timestamp=$(date '+%Y-%m-%d_%H%M%S')
    RUN_DIR="${OUTPUT_DIR}/${run_timestamp}"
    mkdir -p "$RUN_DIR"
    JSON_LOG="${RUN_DIR}/results.json"
    CSV_LOG="${RUN_DIR}/results.csv"

    # Init JSON
    echo '{' > "$JSON_LOG"
    echo "  \"version\": \"${VERSION}\"," >> "$JSON_LOG"
    echo "  \"timestamp\": \"$(timestamp)\"," >> "$JSON_LOG"
    echo "  \"runs_per_test\": ${RUNS}," >> "$JSON_LOG"
    echo "  \"quick_mode\": ${QUICK}," >> "$JSON_LOG"

    # Init CSV
    echo "model,test,status,prompt_tok_s_avg,gen_tok_s_avg,prompt_tok_s_std,gen_tok_s_std,prompt_tokens_avg,gen_tokens_avg,ttft_ms_avg,total_ms_avg" > "$CSV_LOG"

    # Banner
    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║         halo-bench v${VERSION} — LLM Benchmark Suite              ║${NC}"
    echo -e "${BOLD}║         Designed and built by the architect                 ║${NC}"
    echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${DIM}\"Faster, faster, until the thrill of speed${NC}"
    echo -e "  ${DIM} overcomes the fear of death.\" — Hunter S. Thompson${NC}"
    echo ""
    echo -e "  Runs per test:  ${BOLD}${RUNS}${NC}"
    echo -e "  Quick mode:     ${BOLD}${QUICK}${NC}"
    echo -e "  Output:         ${BOLD}${RUN_DIR}${NC}"
    echo ""

    # Hardware info
    collect_hw_info
    echo "  \"results\": [" >> "$JSON_LOG"

    # Determine models to test
    local models=()
    if [[ -n "$MODEL_FILTER" ]]; then
        models+=("$MODEL_FILTER")
    elif $SKIP_LOAD; then
        # Just use whatever is loaded
        local loaded_model
        loaded_model=$(lemonade --port "$LEMONADE_PORT" status 2>/dev/null | grep "llm" | awk '{print $1}' || echo "unknown")
        models+=("$loaded_model")
    else
        # All downloaded LLM models (skip embedding, VL, tiny test models)
        while IFS= read -r line; do
            local model_name
            model_name=$(echo "$line" | awk '{print $1}')
            # Skip non-LLM and tiny models
            case "$model_name" in
                nomic-*|Whisper-*|*embed*|*rerank*|Tiny-*|Qwen3-0.6B*|*VL-*|RealESRGAN*|SD-*|SDXL-*|Z-Image*|Flux-*|kokoro*|Lemonade*|bge-*|jina-*) continue ;;
                *) models+=("$model_name") ;;
            esac
        done < <(lemonade --port "$LEMONADE_PORT" list 2>/dev/null | grep "Yes")
    fi

    if [[ ${#models[@]} -eq 0 ]]; then
        echo -e "${RED}  No models found to benchmark!${NC}"
        exit 1
    fi

    echo -e "  Models to benchmark: ${BOLD}${#models[@]}${NC}"
    for m in "${models[@]}"; do
        echo -e "    ${GREEN}•${NC} $m"
    done

    # Run benchmarks per model
    for model in "${models[@]}"; do
        CURRENT_MODEL="$model"

        header "BENCHMARKING: ${model}"

        if ! $SKIP_LOAD; then
            load_model "$model"
            sleep 3  # Let it warm up
        fi

        # Warm-up request (don't measure)
        echo -e "  ${DIM}Warming up...${NC}"
        curl -s --max-time 30 -X POST "$API_URL" \
            -H "Content-Type: application/json" \
            -d "{\"model\":\"${CURRENT_MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":\"Hi\"}],\"max_tokens\":5,\"stream\":false}" > /dev/null 2>&1

        bench_prompt_scaling
        bench_generation_speed
        bench_context_stress
        bench_reasoning
        bench_code_gen
        if ! $QUICK; then
            bench_multi_turn
            bench_instruction
            bench_concurrency
        fi
        bench_memory
    done

    # Close JSON
    # Remove trailing comma from last result
    sed -i '$ s/,$//' "$JSON_LOG"
    echo "  ]" >> "$JSON_LOG"
    echo "}" >> "$JSON_LOG"

    # Validate JSON
    if python3 -m json.tool "$JSON_LOG" > /dev/null 2>&1; then
        echo ""
        result_line "JSON output valid" "OK"
    else
        warn_line "JSON output" "INVALID" "(may have trailing comma)"
        # Try to fix
        python3 -c "
import json, re
with open('$JSON_LOG') as f:
    text = f.read()
# Remove trailing commas before } or ]
text = re.sub(r',\s*([}\]])', r'\1', text)
data = json.loads(text)
with open('$JSON_LOG', 'w') as f:
    json.dump(data, f, indent=2)
print('  Fixed.')
" 2>/dev/null || true
    fi

    # Generate summary
    header "SUMMARY"
    generate_summary

    echo ""
    echo -e "${BOLD}  Output files:${NC}"
    echo -e "    ${GREEN}•${NC} ${RUN_DIR}/summary.txt"
    echo -e "    ${GREEN}•${NC} ${RUN_DIR}/results.json"
    echo -e "    ${GREEN}•${NC} ${RUN_DIR}/results.csv"
    if [[ -n "$CAST_FILE" ]]; then
        echo -e "    ${GREEN}•${NC} ${RUN_DIR}/${CAST_FILE}"
    fi
    echo ""
    echo -e "  ${DIM}\"I'm not great at the advice. Can I interest you${NC}"
    echo -e "  ${DIM} in a sarcastic comment?\" — Chandler Bing${NC}"
    echo ""
}

main "$@"
