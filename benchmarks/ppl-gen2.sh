#!/usr/bin/env bash
# ppl-gen2.sh — perplexity parity check for halo-server (gen-2 Rust).
#
# Posts the first ~6 KB of wikitext-103 to the gen-2 /ppl endpoint and
# compares the returned perplexity against the gen-1 C++ `bitnet_decode
# --ppl` baseline of **9.1607** (documented 2026-04-19).
#
# Exit codes:
#   0 — gen-2 PPL within tolerance of 9.1607
#   1 — gen-2 PPL diverged beyond tolerance
#   2 — server unreachable, text file missing, or malformed response
#
# Requires: curl, jq.

set -euo pipefail

GEN2=${GEN2:-http://127.0.0.1:8180}
WIKITEXT=${WIKITEXT:-/home/bcloud/halo-ai/datasets/wikitext-103-test.txt}
CHARS=${CHARS:-6000}         # ~1500 BPE tokens; server truncates to max_tokens
STRIDE=${STRIDE:-1024}
MAX_TOKENS=${MAX_TOKENS:-1024}
BASELINE=${BASELINE:-9.1607}
TOLERANCE=${TOLERANCE:-0.05}

have() { command -v "$1" >/dev/null 2>&1; }
have jq   || { echo "need jq";   exit 2; }
have curl || { echo "need curl"; exit 2; }

if [[ ! -f $WIKITEXT ]]; then
    echo "wikitext-103 test file missing at $WIKITEXT" >&2
    echo "expected: wc -l $WIKITEXT  (≥1 line)" >&2
    exit 2
fi

# Pull the first CHARS bytes of the corpus. dd gives us byte-accurate
# truncation so we know roughly how many tokens we're feeding.
TEXT=$(dd if="$WIKITEXT" bs=1 count="$CHARS" status=none)
if [[ -z $TEXT ]]; then
    echo "wikitext slice is empty — $WIKITEXT readable?" >&2
    exit 2
fi

# Build the JSON body with jq (safely escapes the text blob).
BODY=$(jq -n \
    --arg text "$TEXT" \
    --argjson stride "$STRIDE" \
    --argjson max_tokens "$MAX_TOKENS" \
    '{text:$text, stride:$stride, max_tokens:$max_tokens}')

echo "POST $GEN2/ppl  (stride=$STRIDE max_tokens=$MAX_TOKENS, ${#TEXT} bytes of wikitext)"
echo

RAW=$(curl -fsS --max-time 600 \
    -H 'Content-Type: application/json' \
    -d "$BODY" \
    "$GEN2/ppl") || {
    echo "curl failed — is halo-server live on $GEN2?" >&2
    exit 2
}

echo "response: $RAW"
echo

# Parse fields; bail if any are missing.
PPL=$(echo "$RAW"       | jq -r '.perplexity // empty')
MEAN_NLL=$(echo "$RAW"  | jq -r '.mean_nll // empty')
TOKENS=$(echo "$RAW"    | jq -r '.tokens // empty')
ELAPSED=$(echo "$RAW"   | jq -r '.elapsed_ms // empty')

if [[ -z $PPL || -z $MEAN_NLL || -z $TOKENS ]]; then
    echo "malformed response (missing perplexity / mean_nll / tokens)" >&2
    exit 2
fi

printf 'gen-2 result:\n'
printf '  mean_nll    = %s\n' "$MEAN_NLL"
printf '  perplexity  = %s  (baseline %s, tolerance %s)\n' "$PPL" "$BASELINE" "$TOLERANCE"
printf '  tokens      = %s\n' "$TOKENS"
printf '  elapsed_ms  = %s\n' "$ELAPSED"

# Compare in floating-point — bash can't, so delegate to awk.
awk -v p="$PPL" -v b="$BASELINE" -v t="$TOLERANCE" '
BEGIN {
    d = p - b
    ad = (d < 0) ? -d : d
    printf "  delta       = %+.4f\n", d
    if (ad <= t) {
        printf "\nPASS: gen-2 PPL within %.4f of gen-1 baseline %s\n", t, b
        exit 0
    } else {
        printf "\nFAIL: gen-2 PPL diverged by %+.4f from baseline %s (tolerance %s)\n", d, b, t
        exit 1
    }
}'
