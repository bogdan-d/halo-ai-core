#!/bin/bash
# halo-llm-switch.sh — Switch between Lemonade (primary) and llama-server (fallback)
# designed and built by the architect

set -euo pipefail

LEMONADE_URL="http://localhost:13305/api/v1"
LLAMA_URL="http://localhost:8080/v1"
GAIA_ENV="/home/bcloud/gaia/.env"

usage() {
    echo "usage: halo-llm-switch [lemonade|llama|status]"
    echo ""
    echo "  lemonade  — use Lemonade server (default, manages models)"
    echo "  llama     — use llama-server directly (fallback)"
    echo "  status    — show which backend is active"
    exit 1
}

status() {
    echo "=== LLM Backend Status ==="
    if systemctl is-active --quiet lemonade-server; then
        echo "  lemonade-server:  RUNNING (primary)"
        curl -s "$LEMONADE_URL/models" 2>/dev/null | python3 -c "
import sys,json
d=json.load(sys.stdin)
for m in d.get('data',[]):
    print(f\"    model: {m['id']} ({m.get('recipe','?')})\")" 2>/dev/null || echo "    (API not responding)"
    else
        echo "  lemonade-server:  STOPPED"
    fi

    if systemctl is-active --quiet llama-server; then
        echo "  llama-server:     RUNNING (fallback)"
        curl -s "$LLAMA_URL/models" 2>/dev/null | python3 -c "
import sys,json
d=json.load(sys.stdin)
for m in d.get('data',[]):
    print(f\"    model: {m['id']}\")" 2>/dev/null || echo "    (API not responding)"
    else
        echo "  llama-server:     STOPPED"
    fi

    echo ""
    if systemctl is-active --quiet gaia; then
        echo "  gaia API:         RUNNING (:5000)"
    else
        echo "  gaia API:         STOPPED"
    fi
    if systemctl is-active --quiet gaia-ui; then
        echo "  gaia UI:          RUNNING (:4200)"
    else
        echo "  gaia UI:          STOPPED"
    fi
}

switch_to_lemonade() {
    echo "switching to lemonade (primary)..."
    sudo systemctl stop llama-server 2>/dev/null || true
    sudo systemctl start lemonade-server
    sleep 2

    # Update Gaia .env
    sed -i 's|^LEMONADE_BASE_URL=.*|LEMONADE_BASE_URL=http://localhost:13305/api/v1|' "$GAIA_ENV"

    # Restart Gaia services to pick up new URL
    sudo systemctl restart gaia 2>/dev/null || true
    sudo systemctl restart gaia-ui 2>/dev/null || true

    echo "done. gaia -> lemonade:13305 -> llamacpp"
}

switch_to_llama() {
    echo "switching to llama-server (fallback)..."
    sudo systemctl stop lemonade-server 2>/dev/null || true
    sudo systemctl start llama-server
    sleep 3

    # Update Gaia .env — point directly at llama-server's OpenAI API
    sed -i 's|^LEMONADE_BASE_URL=.*|LEMONADE_BASE_URL=http://localhost:8080/v1|' "$GAIA_ENV"

    # Restart Gaia services
    sudo systemctl restart gaia 2>/dev/null || true
    sudo systemctl restart gaia-ui 2>/dev/null || true

    echo "done. gaia -> llama-server:8080 (direct)"
}

case "${1:-status}" in
    lemonade) switch_to_lemonade ;;
    llama)    switch_to_llama ;;
    status)   status ;;
    *)        usage ;;
esac
