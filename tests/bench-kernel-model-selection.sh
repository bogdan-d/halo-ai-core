#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_PATH="${ROOT_DIR}/bench-kernel.sh"

TMP_DIR="$(mktemp -d)"
SERVER_LOG="${TMP_DIR}/server.log"
SERVER_PORT=18991
SERVER_PID=""

cleanup() {
    if [ -n "${SERVER_PID}" ]; then
        kill "${SERVER_PID}" 2>/dev/null || true
        wait "${SERVER_PID}" 2>/dev/null || true
    fi
    rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

python3 - <<'PY' >"${SERVER_LOG}" 2>&1 &
import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse

PORT = 18991

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)

        if parsed.path == "/v1/models":
            body = json.dumps(
                {
                    "object": "list",
                    "data": [
                        {"id": "Gemma-4-26B-A4B-it-GGUF", "object": "model"},
                        {"id": "Qwen3.5-35B-A3B-GGUF", "object": "model"},
                    ],
                }
            ).encode()
        elif parsed.path == "/api/v1/health":
            params = parse_qs(parsed.query)
            if params.get("case") == ["no-llm"]:
                payload = {
                    "status": "ok",
                    "model_loaded": "Whisper-Large-v3-Turbo",
                    "all_models_loaded": [
                        {"model_name": "Whisper-Large-v3-Turbo", "type": "audio"},
                    ],
                }
            else:
                payload = {
                    "status": "ok",
                    "model_loaded": "Qwen3.5-35B-A3B-GGUF",
                    "all_models_loaded": [
                        {"model_name": "Whisper-Large-v3-Turbo", "type": "audio"},
                        {"model_name": "Qwen3.5-35B-A3B-GGUF", "type": "llm"},
                    ],
                }
            body = json.dumps(payload).encode()
        else:
            self.send_response(404)
            self.end_headers()
            return

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        return


HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
PY
SERVER_PID=$!

for _ in $(seq 1 20); do
    if curl -s "http://127.0.0.1:${SERVER_PORT}/api/v1/health" >/dev/null 2>&1; then
        break
    fi
    sleep 0.2
done

TEST_OUTPUT="$(API_URL="http://127.0.0.1:${SERVER_PORT}/v1/chat/completions" \
MODELS_URL="http://127.0.0.1:${SERVER_PORT}/v1/models" \
HEALTH_URL="http://127.0.0.1:${SERVER_PORT}/api/v1/health" \
bash -lc "source '${SCRIPT_PATH}'; resolve_model")"

if [ "${TEST_OUTPUT}" != "Qwen3.5-35B-A3B-GGUF" ]; then
    echo "expected loaded LLM, got: ${TEST_OUTPUT}"
    exit 1
fi

NO_LLM_OUTPUT="$(API_URL="http://127.0.0.1:${SERVER_PORT}/v1/chat/completions" \
MODELS_URL="http://127.0.0.1:${SERVER_PORT}/v1/models" \
HEALTH_URL="http://127.0.0.1:${SERVER_PORT}/api/v1/health?case=no-llm" \
bash -lc "source '${SCRIPT_PATH}'; resolve_model")"

if [ -n "${NO_LLM_OUTPUT}" ]; then
    echo "expected empty output when no llm is loaded, got: ${NO_LLM_OUTPUT}"
    exit 1
fi

echo "ok: resolve_model handles loaded-llm and no-llm cases"
