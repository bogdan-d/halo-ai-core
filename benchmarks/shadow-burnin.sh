#!/usr/bin/env bash
# shadow-burnin.sh — continuous shadow-traffic comparison of gen-1 bitnet_decode (:8080)
# against gen-2 halo-server (:8180). Appends JSONL, maintains resumable state, prints
# summaries on demand or on signal.
#
# Usage:
#   shadow-burnin.sh                    # loop forever
#   shadow-burnin.sh --max-rounds N     # loop N times (0 = forever)
#   shadow-burnin.sh --summary          # print current summary, exit
#   shadow-burnin.sh --summary --since 2026-04-19T12:00:00Z
#
# Output:
#   /home/bcloud/claude output/shadow-burnin.jsonl     — one JSON line per round
#   /home/bcloud/.local/share/halo-ai/shadow-burnin.state  — KEY=VAL counters
#
# Dependencies: bash, jq, curl, flock. No python, no node.

set -euo pipefail

# ---------- configuration ----------
V1_URL="http://127.0.0.1:8080"
V2_URL="http://127.0.0.1:8180"
MODEL="${MODEL:-halo-1bit-2b}"
MAX_TOKENS="${MAX_TOKENS:-64}"
SLEEP_BETWEEN="${SLEEP_BETWEEN:-2}"
REQ_TIMEOUT="${REQ_TIMEOUT:-60}"

PROMPT_FILE="/home/bcloud/halo-ai-core/benchmarks/prompts.txt"
OUT_DIR="/home/bcloud/claude output"
OUT_JSONL="${OUT_DIR}/shadow-burnin.jsonl"
STATE_DIR="/home/bcloud/.local/share/halo-ai"
STATE_FILE="${STATE_DIR}/shadow-burnin.state"
LOCK_FILE="/tmp/shadow-burnin.lock"

# ---------- arg parse ----------
MAX_ROUNDS=0          # 0 = infinite
SUMMARY_ONLY=0
SUMMARY_SINCE=""

usage() {
    sed -n '2,16p' "$0"
    exit 2
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --max-rounds)
            [[ $# -ge 2 ]] || usage
            MAX_ROUNDS="$2"
            [[ "$MAX_ROUNDS" =~ ^[0-9]+$ ]] || { echo "--max-rounds must be a non-negative integer" >&2; exit 2; }
            shift 2
            ;;
        --summary)
            SUMMARY_ONLY=1
            shift
            ;;
        --since)
            [[ $# -ge 2 ]] || usage
            SUMMARY_SINCE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "unknown arg: $1" >&2
            usage
            ;;
    esac
done

# ---------- dep checks ----------
have() { command -v "$1" >/dev/null 2>&1; }
have jq    || { echo "fatal: need jq"    >&2; exit 2; }
have curl  || { echo "fatal: need curl"  >&2; exit 2; }
have flock || { echo "fatal: need flock" >&2; exit 2; }

mkdir -p "$OUT_DIR" "$STATE_DIR"

# ---------- state helpers ----------
declare -A STATE=(
    [rounds]=0
    [exact_matches]=0
    [prefix_only_matches]=0
    [no_match]=0
    [v1_unreachable]=0
    [v2_unreachable]=0
    [prefix_chars_total]=0
    [v1_ms_total]=0
    [v2_ms_total]=0
    [started_at]=""
    [last_ts]=""
)

load_state() {
    [[ -f "$STATE_FILE" ]] || return 0
    local line k v
    while IFS='=' read -r k v; do
        [[ -z "$k" || "$k" =~ ^# ]] && continue
        STATE[$k]="$v"
    done < "$STATE_FILE"
}

save_state() {
    local tmp="${STATE_FILE}.tmp.$$"
    {
        echo "# shadow-burnin.state — generated $(date -u +%Y-%m-%dT%H:%M:%SZ)"
        for k in rounds exact_matches prefix_only_matches no_match \
                 v1_unreachable v2_unreachable prefix_chars_total \
                 v1_ms_total v2_ms_total started_at last_ts; do
            printf '%s=%s\n' "$k" "${STATE[$k]:-}"
        done
    } > "$tmp"
    mv -f "$tmp" "$STATE_FILE"
}

# ---------- prompt loading ----------
load_prompts() {
    [[ -f "$PROMPT_FILE" ]] || { echo "fatal: prompt file missing: $PROMPT_FILE" >&2; exit 2; }
    PROMPTS=()
    local line
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ -z "$line" || "$line" =~ ^# ]] && continue
        PROMPTS+=("$line")
    done < "$PROMPT_FILE"
    [[ ${#PROMPTS[@]} -gt 0 ]] || { echo "fatal: prompt file has no usable lines: $PROMPT_FILE" >&2; exit 2; }
}

# ---------- backend call ----------
# ask <url> <prompt> -> echoes "<elapsed_ms>\t<text>\t<tokens>" on success;
# exits nonzero on failure.
ask() {
    local url="$1" prompt="$2"
    local body
    body=$(jq -n --arg m "$MODEL" --arg p "$prompt" --argjson n "$MAX_TOKENS" \
        '{model:$m, messages:[{role:"user",content:$p}], max_tokens:$n, temperature:0, stream:false}')

    local t0 t1 resp
    t0=$(date +%s%3N)
    resp=$(curl -fsS --max-time "$REQ_TIMEOUT" "${url}/v1/chat/completions" \
           -H 'Content-Type: application/json' \
           -d "$body") || return 1
    t1=$(date +%s%3N)

    local text tokens
    text=$(printf '%s' "$resp" | jq -r '.choices[0].message.content // ""')
    tokens=$(printf '%s' "$resp" | jq -r '(.usage.completion_tokens // .usage.total_tokens // 0)')
    printf '%s\t%s\t%s' "$((t1 - t0))" "$text" "$tokens"
}

# ---------- prefix match length in chars ----------
prefix_match_len() {
    local a="$1" b="$2"
    local i=0 n=${#a} m=${#b}
    local lim=$(( n < m ? n : m ))
    while (( i < lim )); do
        [[ "${a:i:1}" == "${b:i:1}" ]] || break
        i=$((i + 1))
    done
    echo "$i"
}

# ---------- summary ----------
percentile() {
    # usage: percentile <p> <sorted_values...>
    local p="$1"; shift
    local n=$#
    [[ $n -eq 0 ]] && { echo "-"; return; }
    local idx=$(( (p * (n - 1) + 50) / 100 ))
    eval "echo \${$((idx + 1))}"
}

print_summary() {
    local rounds="${STATE[rounds]:-0}"
    local exact="${STATE[exact_matches]:-0}"
    local prefonly="${STATE[prefix_only_matches]:-0}"
    local nomatch="${STATE[no_match]:-0}"
    local v1un="${STATE[v1_unreachable]:-0}"
    local v2un="${STATE[v2_unreachable]:-0}"
    local since="$SUMMARY_SINCE"

    local match_rate="-" median_prefix="-" v1_p95="-" v2_p95="-"
    local counted=0

    if [[ -f "$OUT_JSONL" ]]; then
        local filter='.'
        if [[ -n "$since" ]]; then
            filter=". as \$r | if (\$r.ts >= \"$since\") then \$r else empty end"
        fi

        # pull numeric fields from (possibly-filtered) jsonl
        local tmp_pref tmp_v1 tmp_v2
        tmp_pref=$(mktemp); tmp_v1=$(mktemp); tmp_v2=$(mktemp)
        # shellcheck disable=SC2064
        trap "rm -f '$tmp_pref' '$tmp_v1' '$tmp_v2'" RETURN

        jq -r "$filter | select((.v1_unreachable // false) | not) | select((.v2_unreachable // false) | not) | (.prefix_match_chars // 0)" \
            "$OUT_JSONL" 2>/dev/null | sort -n > "$tmp_pref" || true
        jq -r "$filter | (.v1_ms // empty)" "$OUT_JSONL" 2>/dev/null | sort -n > "$tmp_v1" || true
        jq -r "$filter | (.v2_ms // empty)" "$OUT_JSONL" 2>/dev/null | sort -n > "$tmp_v2" || true

        local exact_c prefonly_c nomatch_c v1u_c v2u_c
        exact_c=$(jq -r "$filter | select(.full_match == true) | 1" "$OUT_JSONL" 2>/dev/null | wc -l)
        prefonly_c=$(jq -r "$filter | select((.full_match == false) and ((.prefix_match_chars // 0) > 0)) | 1" "$OUT_JSONL" 2>/dev/null | wc -l)
        nomatch_c=$(jq -r "$filter | select((.full_match == false) and ((.prefix_match_chars // 0) == 0) and ((.v1_unreachable // false) | not) and ((.v2_unreachable // false) | not)) | 1" "$OUT_JSONL" 2>/dev/null | wc -l)
        v1u_c=$(jq -r "$filter | select(.v1_unreachable == true) | 1" "$OUT_JSONL" 2>/dev/null | wc -l)
        v2u_c=$(jq -r "$filter | select(.v2_unreachable == true) | 1" "$OUT_JSONL" 2>/dev/null | wc -l)
        counted=$(jq -r "$filter | 1" "$OUT_JSONL" 2>/dev/null | wc -l)

        if [[ -n "$since" ]]; then
            rounds=$counted
            exact=$exact_c
            prefonly=$prefonly_c
            nomatch=$nomatch_c
            v1un=$v1u_c
            v2un=$v2u_c
        fi

        if [[ $(wc -l < "$tmp_pref") -gt 0 ]]; then
            # median
            mapfile -t _pref < "$tmp_pref"
            median_prefix=$(percentile 50 "${_pref[@]}")
        fi
        if [[ $(wc -l < "$tmp_v1") -gt 0 ]]; then
            mapfile -t _v1 < "$tmp_v1"
            v1_p95=$(percentile 95 "${_v1[@]}")
        fi
        if [[ $(wc -l < "$tmp_v2") -gt 0 ]]; then
            mapfile -t _v2 < "$tmp_v2"
            v2_p95=$(percentile 95 "${_v2[@]}")
        fi
    fi

    local comparable=$((rounds - v1un - v2un))
    if (( comparable > 0 )); then
        # two-decimal percent via integer math
        local bp=$(( (exact * 10000) / comparable ))
        match_rate=$(printf '%d.%02d%%' $((bp / 100)) $((bp % 100)))
    fi

    echo "==== shadow-burnin summary ===="
    [[ -n "$since" ]] && echo "since            : $since"
    echo "rounds           : $rounds"
    echo "exact matches    : $exact"
    echo "prefix-only      : $prefonly"
    echo "no match         : $nomatch"
    echo "v1 unreachable   : $v1un"
    echo "v2 unreachable   : $v2un"
    echo "exact-match rate : $match_rate   (exact / comparable)"
    echo "median prefix len: $median_prefix chars"
    echo "v1 p95 latency   : $v1_p95 ms"
    echo "v2 p95 latency   : $v2_p95 ms"
    echo "started_at       : ${STATE[started_at]:-}"
    echo "last_ts          : ${STATE[last_ts]:-}"
    echo "================================="
}

# ---------- --summary path: no lock, no loop ----------
if [[ $SUMMARY_ONLY -eq 1 ]]; then
    load_state
    print_summary
    exit 0
fi

# ---------- acquire lock ----------
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
    echo "fatal: another shadow-burnin is running (lock: $LOCK_FILE)" >&2
    exit 2
fi

# ---------- main loop ----------
load_prompts
load_state

if [[ -z "${STATE[started_at]:-}" ]]; then
    STATE[started_at]=$(date -u +%Y-%m-%dT%H:%M:%SZ)
fi

resume_rounds="${STATE[rounds]:-0}"
prompt_idx=$(( resume_rounds % ${#PROMPTS[@]} ))

shutdown=0
on_signal() {
    shutdown=1
}
trap on_signal INT TERM

round_in_session=0

while :; do
    if (( shutdown )); then break; fi
    if (( MAX_ROUNDS > 0 && round_in_session >= MAX_ROUNDS )); then break; fi

    prompt="${PROMPTS[$prompt_idx]}"
    snippet="${prompt:0:60}"

    ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    v1_ok=1; v2_ok=1
    v1_ms=0; v2_ms=0
    v1_text=""; v2_text=""
    v1_tok=0; v2_tok=0

    if v1_raw=$(ask "$V1_URL" "$prompt" 2>/dev/null); then
        IFS=$'\t' read -r v1_ms v1_text v1_tok <<<"$v1_raw"
    else
        v1_ok=0
        STATE[v1_unreachable]=$(( ${STATE[v1_unreachable]:-0} + 1 ))
    fi

    if v2_raw=$(ask "$V2_URL" "$prompt" 2>/dev/null); then
        IFS=$'\t' read -r v2_ms v2_text v2_tok <<<"$v2_raw"
    else
        v2_ok=0
        STATE[v2_unreachable]=$(( ${STATE[v2_unreachable]:-0} + 1 ))
    fi

    STATE[rounds]=$(( ${STATE[rounds]:-0} + 1 ))
    STATE[last_ts]="$ts"

    if (( v1_ok && v2_ok )); then
        prefix=$(prefix_match_len "$v1_text" "$v2_text")
        if [[ "$v1_text" == "$v2_text" ]]; then
            full_match=true
            STATE[exact_matches]=$(( ${STATE[exact_matches]:-0} + 1 ))
        else
            full_match=false
            if (( prefix > 0 )); then
                STATE[prefix_only_matches]=$(( ${STATE[prefix_only_matches]:-0} + 1 ))
            else
                STATE[no_match]=$(( ${STATE[no_match]:-0} + 1 ))
            fi
        fi
        STATE[prefix_chars_total]=$(( ${STATE[prefix_chars_total]:-0} + prefix ))
        STATE[v1_ms_total]=$(( ${STATE[v1_ms_total]:-0} + v1_ms ))
        STATE[v2_ms_total]=$(( ${STATE[v2_ms_total]:-0} + v2_ms ))

        jq -cn \
            --arg ts "$ts" \
            --argjson idx "$prompt_idx" \
            --arg snippet "$snippet" \
            --argjson prefix "$prefix" \
            --argjson full "$full_match" \
            --argjson v1_ms "$v1_ms" \
            --argjson v2_ms "$v2_ms" \
            --arg v1_text "$v1_text" \
            --arg v2_text "$v2_text" \
            --argjson v1_tokens "${v1_tok:-0}" \
            --argjson v2_tokens "${v2_tok:-0}" \
            '{ts:$ts, prompt_idx:$idx, prompt_snippet:$snippet,
              prefix_match_chars:$prefix, full_match:$full,
              v1_ms:$v1_ms, v2_ms:$v2_ms,
              v1_text:$v1_text, v2_text:$v2_text,
              v1_tokens:$v1_tokens, v2_tokens:$v2_tokens}' \
            >> "$OUT_JSONL"
    else
        jq -cn \
            --arg ts "$ts" \
            --argjson idx "$prompt_idx" \
            --arg snippet "$snippet" \
            --argjson v1_un $([[ $v1_ok -eq 0 ]] && echo true || echo false) \
            --argjson v2_un $([[ $v2_ok -eq 0 ]] && echo true || echo false) \
            '{ts:$ts, prompt_idx:$idx, prompt_snippet:$snippet,
              v1_unreachable:$v1_un, v2_unreachable:$v2_un}' \
            >> "$OUT_JSONL"
    fi

    save_state

    prompt_idx=$(( (prompt_idx + 1) % ${#PROMPTS[@]} ))
    round_in_session=$(( round_in_session + 1 ))

    if (( shutdown )); then break; fi
    if (( MAX_ROUNDS > 0 && round_in_session >= MAX_ROUNDS )); then break; fi

    sleep "$SLEEP_BETWEEN" &
    sleep_pid=$!
    wait "$sleep_pid" 2>/dev/null || true
done

save_state
print_summary
exit 0
