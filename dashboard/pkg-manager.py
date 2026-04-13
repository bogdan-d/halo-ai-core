#!/usr/bin/env python3
"""halo-ai-core Package Manager — self-contained service management.

Part of the Lemonade stack. Independent from OS package manager.
Manages install, update, rollback, status for all halo services.
"""

import json
import os
import shlex
import signal
import subprocess
import sys
import time
from datetime import datetime, timezone
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path

# ── Paths ──────────────────────────────────────────────────────────
HALO_ROOT = Path.home() / "halo-ai-core"
PKG_DB = HALO_ROOT / "dashboard" / "packages.json"
LOG_DIR = Path.home() / ".local" / "log"

# ── Package Registry ───────────────────────────────────────────────
# Each package: name, binary/service, build cmd, source, version detection
REGISTRY = {
    "lemonade-server": {
        "description": "Lemonade LLM Gateway Server",
        "category": "llm",
        "service": "lemonade-server.service",
        "binary": "/usr/bin/lemond",
        "version_cmd": "lemonade --version 2>/dev/null | grep -oP '[0-9]+\\.[0-9]+\\.[0-9]+' | head -1",
        "source": "pacman:lemonade-server",
        "ports": [13305],
    },
    "lemonade-nexus": {
        "description": "Cryptographic WireGuard Mesh VPN",
        "category": "network",
        "service": "lemonade-nexus.service",
        "binary": "/usr/local/bin/lemonade-nexus",
        "version_cmd": "cd ~/lemonade-nexus && git describe --tags 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo built",
        "source": "git:~/lemonade-nexus",
        "build_cmd": "cd ~/lemonade-nexus/build && cmake .. && make -j$(nproc)",
        "ports": [9100, 9101, 9102, 51940],
    },
    "llama-vulkan": {
        "description": "llama.cpp Inference (Vulkan backend)",
        "category": "llm",
        "service": None,
        "binary": "/usr/local/bin/llama-server-vulkan",
        "version_cmd": "cd ~/llama.cpp && git describe --tags 2>/dev/null || git rev-parse --short HEAD 2>/dev/null",
        "source": "git:~/llama.cpp",
        "build_cmd": "cd ~/llama.cpp && cmake -B build-vulkan -DGGML_VULKAN=ON && cmake --build build-vulkan -j$(nproc)",
    },
    "llama-rocm": {
        "description": "llama.cpp Inference (ROCm/HIP backend)",
        "category": "llm",
        "service": "llama-server.service",
        "binary": "/usr/local/bin/llama-server",
        "version_cmd": "cd ~/llama.cpp && git describe --tags 2>/dev/null || git rev-parse --short HEAD 2>/dev/null",
        "source": "git:~/llama.cpp",
        "build_cmd": "cd ~/llama.cpp && cmake -B build-rocm -DGGML_HIP=ON && cmake --build build-rocm -j$(nproc)",
        "ports": [8080],
    },
    "flm": {
        "description": "FastFlowLM — NPU Inference",
        "category": "npu",
        "service": None,
        "binary": "/usr/bin/flm",
        "version_cmd": "flm version --json 2>&1 | grep -oP '\"version\":\\s*\"\\K[^\"]+' || flm version 2>&1",
        "source": "pacman:fastflowlm",
        "ports": [],
    },
    "vllm": {
        "description": "vLLM — High-throughput LLM Serving (ROCm)",
        "category": "llm",
        "service": None,
        "binary": None,
        "version_cmd": "python3 -c 'import vllm; print(vllm.__version__)' 2>/dev/null",
        "source": "pip:vllm",
    },
    "comfyui": {
        "description": "ComfyUI — Image/Video/Audio Generation",
        "category": "media",
        "service": "comfyui.service",
        "binary": None,
        "version_cmd": "cd ~/comfyui && git describe --tags 2>/dev/null || git rev-parse --short HEAD",
        "source": "git:~/comfyui",
        "ports": [8188],
    },
    "stable-diffusion-cpp": {
        "description": "stable-diffusion.cpp — Fast SD Inference",
        "category": "media",
        "service": None,
        "binary": None,
        "version_cmd": "cd ~/stable-diffusion.cpp && git describe --tags 2>/dev/null || git rev-parse --short HEAD",
        "source": "git:~/stable-diffusion.cpp",
    },
    "gaia": {
        "description": "Gaia AI Agent Framework",
        "category": "agents",
        "service": "gaia.service",
        "binary": "~/gaia-env/bin/gaia",
        "version_cmd": "~/gaia-env/bin/gaia --version 2>&1 | head -1",
        "source": "git:~/gaia",
        "ports": [5050],
    },
    "gaia-ui": {
        "description": "Gaia Agent Web UI",
        "category": "agents",
        "service": "gaia-ui.service",
        "binary": None,
        "version_cmd": None,
        "source": "git:~/gaia",
        "ports": [4200],
    },
    "living-mind-cortex": {
        "description": "Bio-Inspired Cognitive Backend",
        "category": "agents",
        "service": "living-mind-cortex.service",
        "binary": None,
        "version_cmd": None,
        "source": "git:~/living-mind",
        "ports": [8095],
    },
    "reversellm": {
        "description": "KV-cache-aware Reverse Proxy",
        "category": "llm",
        "service": "reversellm@default.service",
        "binary": None,
        "version_cmd": None,
        "source": "git:~/reversellm",
        "ports": [8008],
    },
    "caddy": {
        "description": "Caddy Web Server / Reverse Proxy",
        "category": "network",
        "service": "caddy.service",
        "binary": "/usr/bin/caddy",
        "version_cmd": "caddy version 2>&1 | grep -oP 'v[0-9]+\\.[0-9]+\\.[0-9]+' | head -1",
        "source": "pacman:caddy",
        "ports": [80, 443],
    },
    "searxng": {
        "description": "SearXNG — Privacy Search Engine (Podman)",
        "category": "network",
        "service": None,
        "binary": None,
        "version_cmd": "podman inspect searxng --format '{{.Config.Image}}' 2>/dev/null",
        "source": "podman:searxng",
        "ports": [8888],
    },
    "interviewer": {
        "description": "AI-Powered Interview Practice",
        "category": "agents",
        "service": None,
        "binary": None,
        "version_cmd": "cd ~/interviewer && node -e \"console.log(require('./package.json').version)\" 2>/dev/null",
        "source": "git:~/interviewer",
    },
    "postgresql": {
        "description": "PostgreSQL Database",
        "category": "data",
        "service": "postgresql.service",
        "binary": "/usr/bin/postgres",
        "version_cmd": "postgres --version 2>&1 | grep -oP '[0-9]+\\.[0-9]+' | head -1",
        "source": "pacman:postgresql",
        "ports": [5432],
    },
}

CATEGORY_COLORS = {
    "llm": "gpu",
    "npu": "npu",
    "media": "img",
    "agents": "accent",
    "network": "green",
    "data": "orange",
}


def run_cmd(cmd, timeout=10):
    """Run a shell command and return stdout."""
    try:
        r = subprocess.run(
            cmd, shell=True, capture_output=True, text=True, timeout=timeout
        )
        return r.stdout.strip()
    except Exception:
        return ""


def get_service_status(svc):
    """Get systemd service status."""
    if not svc:
        return "n/a"
    out = run_cmd(f"systemctl is-active {shlex.quote(svc)}")
    return out if out else "unknown"


def get_package_state(name, pkg):
    """Get full state for a single package."""
    status = get_service_status(pkg.get("service"))
    version = run_cmd(pkg["version_cmd"]) if pkg.get("version_cmd") else "—"
    binary_exists = True
    if pkg.get("binary"):
        binary_exists = os.path.exists(os.path.expanduser(pkg["binary"]))

    # Check if source dir exists for git packages
    source_exists = True
    src = pkg.get("source", "")
    if src.startswith("git:"):
        src_path = os.path.expanduser(src[4:])
        source_exists = os.path.isdir(src_path)

    # Podman container check
    if src.startswith("podman:"):
        container = src[7:]
        running = run_cmd(f"podman ps --filter name={container} --format '{{{{.Status}}}}'")
        status = "active" if running else "inactive"

    return {
        "name": name,
        "description": pkg["description"],
        "category": pkg.get("category", "other"),
        "service": pkg.get("service"),
        "status": status,
        "version": version or "—",
        "binary_exists": binary_exists,
        "source_exists": source_exists,
        "source": pkg.get("source", ""),
        "ports": pkg.get("ports", []),
        "build_cmd": pkg.get("build_cmd"),
    }


def get_all_packages():
    """Get state of all registered packages."""
    packages = []
    for name, pkg in REGISTRY.items():
        packages.append(get_package_state(name, pkg))
    return packages


def service_action(service, action):
    """Start/stop/restart a systemd service."""
    if action not in ("start", "stop", "restart"):
        return {"error": f"Invalid action: {action}"}
    if not service:
        return {"error": "No service defined"}
    result = run_cmd(f"sudo systemctl {action} {shlex.quote(service)}", timeout=30)
    new_status = get_service_status(service)
    return {"service": service, "action": action, "status": new_status}


def get_system_summary():
    """Quick summary stats."""
    active = 0
    failed = 0
    total = len(REGISTRY)
    for name, pkg in REGISTRY.items():
        st = get_service_status(pkg.get("service"))
        if st == "active":
            active += 1
        elif st == "failed":
            failed += 1
    return {
        "total": total,
        "active": active,
        "failed": failed,
        "inactive": total - active - failed,
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


# ── HTTP Server ────────────────────────────────────────────────────
class PkgHandler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass  # silent

    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def _json(self, data, status=200):
        body = json.dumps(data).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self._cors()
        self.end_headers()
        self.wfile.write(body)

    def _html(self, path):
        try:
            content = Path(path).read_bytes()
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self._cors()
            self.end_headers()
            self.wfile.write(content)
        except FileNotFoundError:
            self.send_error(404)

    def do_OPTIONS(self):
        self.send_response(204)
        self._cors()
        self.end_headers()

    def do_GET(self):
        if self.path == "/" or self.path == "/packages":
            self._html(HALO_ROOT / "dashboard" / "packages.html")
        elif self.path == "/api/packages":
            self._json(get_all_packages())
        elif self.path == "/api/summary":
            self._json(get_system_summary())
        elif self.path.startswith("/api/package/"):
            name = self.path.split("/")[-1]
            if name in REGISTRY:
                self._json(get_package_state(name, REGISTRY[name]))
            else:
                self._json({"error": "Package not found"}, 404)
        else:
            self.send_error(404)

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(length)) if length else {}

        if self.path == "/api/service":
            svc = body.get("service")
            action = body.get("action")
            self._json(service_action(svc, action))
        elif self.path == "/api/build":
            name = body.get("package")
            if name in REGISTRY and REGISTRY[name].get("build_cmd"):
                cmd = REGISTRY[name]["build_cmd"]
                log_file = LOG_DIR / f"build-{name}.log"
                LOG_DIR.mkdir(parents=True, exist_ok=True)
                subprocess.Popen(
                    f"({cmd}) > {log_file} 2>&1",
                    shell=True,
                )
                self._json({"package": name, "status": "building", "log": str(log_file)})
            else:
                self._json({"error": "No build command"}, 400)
        else:
            self.send_error(404)


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 3010
    server = HTTPServer(("127.0.0.1", port), PkgHandler)
    signal.signal(signal.SIGINT, lambda *_: sys.exit(0))
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    print(f"[pkg-manager] Listening on http://127.0.0.1:{port}")
    server.serve_forever()


if __name__ == "__main__":
    main()
