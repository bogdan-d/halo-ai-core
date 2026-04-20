#!/usr/bin/env bash
# parity.sh — shadow compare gen-1 (:8080) vs gen-2 (:8180).
# Deterministic (temperature=0), same prompt + max_tokens, diff outputs.
# Exit 0 identical; 1 divergent; 2 either backend unreachable.

set -euo pipefail

V1=http://127.0.0.1:8080
V2=http://127.0.0.1:8180
MAX=${MAX:-32}
MODEL=${MODEL:-halo-1bit-2b}
PROMPTS=(
    "The capital of France is"
    "In computer science, a binary tree is"
    "The quick brown fox jumps over"
)

have() { command -v "$1" >/dev/null 2>&1; }
have jq   || { echo "need jq";   exit 2; }
have curl || { echo "need curl"; exit 2; }

ask() {
    local url=$1 prompt=$2
    curl -fsS --max-time 30 "${url}/v1/chat/completions" \
        -H 'Content-Type: application/json' \
        -d "$(jq -n --arg m "$MODEL" --arg p "$prompt" --argjson n "$MAX" \
              '{model:$m, messages:[{role:"user",content:$p}], max_tokens:$n, temperature:0, stream:false}')" \
        | jq -r '.choices[0].message.content'
}

printf '%-40s  %s\n' "prompt" "result"
divergent=0
for p in "${PROMPTS[@]}"; do
    a=$(ask "$V1" "$p" 2>/dev/null) || { echo "v1 unreachable for: $p"; exit 2; }
    b=$(ask "$V2" "$p" 2>/dev/null) || { echo "v2 unreachable for: $p"; exit 2; }
    if [[ "$a" == "$b" ]]; then
        printf '✓  %-38s  match (%d chars)\n' "${p:0:38}" "${#a}"
    else
        divergent=$((divergent+1))
        printf '✗  %-38s  DIVERGE\n' "${p:0:38}"
        echo "    v1: ${a:0:120}"
        echo "    v2: ${b:0:120}"
    fi
done

echo
if [[ $divergent -eq 0 ]]; then
    echo "parity: ALL ${#PROMPTS[@]} prompts match"
    exit 0
else
    echo "parity: $divergent / ${#PROMPTS[@]} prompts diverge"
    exit 1
fi
