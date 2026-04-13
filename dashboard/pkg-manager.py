#!/usr/bin/env python3
"""halo-ai-core Unified Package Manager + Hardware Stats Server.

Merges pkg-manager.py (:3010) and stats-server.py (:5090) into one.
Part of the Lemonade stack. Designed and built by the architect.
"""

import json
import os
import shlex
import signal
import subprocess
import sys
import time
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path

import psutil

# ── Paths ──────────────────────────────────────────────────────────
HALO_ROOT = Path.home() / "halo-ai-core"
LOG_DIR = Path.home() / ".local" / "log"
FREEZE_FILE = "/srv/halo-dashboard/.freeze.json"

# ── Package Registry ───────────────────────────────────────────────
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
        "description": "FastFlowLM -- NPU Inference",
        "category": "npu",
        "service": None,
        "binary": "/usr/bin/flm",
        "version_cmd": "flm version --json 2>&1 | grep -oP '\"version\":\\s*\"\\K[^\"]+' || flm version 2>&1",
        "source": "pacman:fastflowlm",
        "ports": [],
    },
    "vllm": {
        "description": "vLLM -- High-throughput LLM Serving (ROCm)",
        "category": "llm",
        "service": None,
        "binary": None,
        "version_cmd": "python3 -c 'import vllm; print(vllm.__version__)' 2>/dev/null",
        "source": "pip:vllm",
    },
    "comfyui": {
        "description": "ComfyUI -- Image/Video/Audio Generation",
        "category": "media",
        "service": "comfyui.service",
        "binary": None,
        "version_cmd": "cd ~/comfyui && git describe --tags 2>/dev/null || git rev-parse --short HEAD",
        "source": "git:~/comfyui",
        "ports": [8188],
    },
    "stable-diffusion-cpp": {
        "description": "stable-diffusion.cpp -- Fast SD Inference",
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
        "description": "SearXNG -- Privacy Search Engine (Podman)",
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


# ── Nexus VPN ──────────────────────────────────────────────────────
# SSH Mesh deprecated. Nexus replaces it.


# ── Safe Terminal Commands ─────────────────────────────────────────
SAFE_PREFIXES = [
    "systemctl --user status", "systemctl --user list-units",
    "systemctl status", "journalctl",
    "uname", "uptime", "free", "df", "lscpu", "lspci",
    "ip addr", "ip link", "ss -tlnp",
    "pacman -Q", "pyenv versions",
    "lemonade status", "lemonade list", "lemonade backends",
    "cat /proc/cpuinfo", "cat /proc/meminfo",
    "ls", "pwd", "whoami", "hostname", "date",
    "rocminfo", "rocm-smi",
    "neofetch", "fastfetch",
]


# ── LLM Stats Cache ───────────────────────────────────────────────
_last_llm_stats = {
    "model": "", "prompt_tps": 0, "gen_tps": 0,
    "ttft_ms": 0, "ctx_used": 0, "ctx_max": 0, "backend": "",
}


# ══════════════════════════════════════════════════════════════════
#  Utility
# ══════════════════════════════════════════════════════════════════

def run_cmd(cmd, timeout=10):
    """Run a shell command and return stdout."""
    try:
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
        return r.stdout.strip()
    except Exception:
        return ""


# ══════════════════════════════════════════════════════════════════
#  Hardware Stats
# ══════════════════════════════════════════════════════════════════

def get_hw_info():
    """Static hardware identity."""
    cpu_name = "Unknown CPU"
    try:
        with open("/proc/cpuinfo") as f:
            for line in f:
                if line.startswith("model name"):
                    cpu_name = line.split(":")[1].strip()
                    break
    except Exception:
        pass

    gpu_name = "N/A"
    try:
        name_f = "/sys/class/drm/card1/device/product_name"
        if os.path.exists(name_f):
            gpu_name = open(name_f).read().strip()
        else:
            vendor_f = "/sys/class/drm/card1/device/vendor"
            if os.path.exists(vendor_f):
                gpu_name = "AMD Radeon (integrated)"
    except Exception:
        pass

    vram_total = 0
    try:
        vf = "/sys/class/drm/card1/device/mem_info_vram_total"
        if os.path.exists(vf):
            vram_total = int(open(vf).read().strip())
    except Exception:
        pass

    mem = psutil.virtual_memory()
    disk = psutil.disk_usage("/")

    return {
        "cpu": cpu_name,
        "cores": psutil.cpu_count(logical=True),
        "ram_total": mem.total,
        "gpu": gpu_name,
        "vram_total": vram_total,
        "npu": "AMD XDNA" if os.path.exists("/dev/accel/accel0") else "N/A",
        "disk_total": disk.total,
    }


def get_gpu_stats():
    """Live GPU stats from sysfs."""
    gpu = {"temp": 0, "usage": 0, "vram_used": 0, "vram_total": 0}
    try:
        hwmon_base = "/sys/class/drm/card1/device/hwmon"
        if os.path.isdir(hwmon_base):
            hwmon = os.path.join(hwmon_base, os.listdir(hwmon_base)[0])
            temp_file = os.path.join(hwmon, "temp1_input")
            if os.path.exists(temp_file):
                gpu["temp"] = int(open(temp_file).read().strip()) // 1000

        busy = "/sys/class/drm/card1/device/gpu_busy_percent"
        if os.path.exists(busy):
            gpu["usage"] = int(open(busy).read().strip())

        vram_used_f = "/sys/class/drm/card1/device/mem_info_vram_used"
        vram_total_f = "/sys/class/drm/card1/device/mem_info_vram_total"
        if os.path.exists(vram_used_f):
            gpu["vram_used"] = int(open(vram_used_f).read().strip())
            gpu["vram_total"] = int(open(vram_total_f).read().strip())
    except Exception:
        pass
    return gpu


def get_live_stats():
    """Live performance stats."""
    mem = psutil.virtual_memory()
    disk = psutil.disk_usage("/")
    cpu_freq = psutil.cpu_freq()
    temps = {}
    try:
        t = psutil.sensors_temperatures()
        if "k10temp" in t:
            temps["cpu"] = t["k10temp"][0].current
        elif "coretemp" in t:
            temps["cpu"] = t["coretemp"][0].current
    except Exception:
        pass

    gpu = get_gpu_stats()
    net = psutil.net_io_counters()
    uptime = time.time() - psutil.boot_time()

    return {
        "cpu": {
            "usage": psutil.cpu_percent(interval=0.5),
            "freq": round(cpu_freq.current) if cpu_freq else 0,
            "temp": round(temps.get("cpu", 0)),
        },
        "ram": {
            "used": mem.used,
            "total": mem.total,
            "percent": mem.percent,
        },
        "disk": {
            "used": disk.used,
            "total": disk.total,
            "percent": disk.percent,
        },
        "gpu": gpu,
        "npu_online": os.path.exists("/dev/accel/accel0"),
        "net": {
            "sent": net.bytes_sent,
            "recv": net.bytes_recv,
        },
        "uptime": int(uptime),
    }


# ══════════════════════════════════════════════════════════════════
#  Package Management
# ══════════════════════════════════════════════════════════════════

def get_service_status(svc):
    """Get systemd service status."""
    if not svc:
        return "n/a"
    out = run_cmd(f"systemctl is-active {shlex.quote(svc)}")
    return out if out else "unknown"


def get_package_state(name, pkg):
    """Get full state for a single package."""
    status = get_service_status(pkg.get("service"))
    version = run_cmd(pkg["version_cmd"]) if pkg.get("version_cmd") else ""
    binary_exists = True
    if pkg.get("binary"):
        binary_exists = os.path.exists(os.path.expanduser(pkg["binary"]))

    source_exists = True
    src = pkg.get("source", "")
    if src.startswith("git:"):
        src_path = os.path.expanduser(src[4:])
        source_exists = os.path.isdir(src_path)

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
        "version": version or "",
        "binary_exists": binary_exists,
        "source_exists": source_exists,
        "source": pkg.get("source", ""),
        "ports": pkg.get("ports", []),
        "build_cmd": pkg.get("build_cmd"),
    }


def get_all_packages():
    """Get state of all registered packages."""
    return [get_package_state(name, pkg) for name, pkg in REGISTRY.items()]


def get_system_summary():
    """Quick summary stats."""
    active = failed = 0
    total = len(REGISTRY)
    for _name, pkg in REGISTRY.items():
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


def service_action(service, action):
    """Start/stop/restart a systemd service."""
    if action not in ("start", "stop", "restart"):
        return {"error": f"Invalid action: {action}"}
    if not service:
        return {"error": "No service defined"}
    result = run_cmd(f"sudo systemctl {action} {shlex.quote(service)}", timeout=30)
    new_status = get_service_status(service)
    return {"service": service, "action": action, "status": new_status}


# ══════════════════════════════════════════════════════════════════
#  Lemonade Control
# ══════════════════════════════════════════════════════════════════

def get_lemonade_status():
    """Parse lemonade status for loaded models and server info."""
    try:
        r = subprocess.run(["lemonade", "status"], capture_output=True, text=True, timeout=10)
        out = r.stdout + r.stderr
        result = {"running": False, "version": "", "models": [], "raw": out[:500]}
        if "running" in out.lower():
            result["running"] = True
        for line in out.split("\n"):
            if "Version" in line and "Value" not in line:
                result["version"] = line.split()[-1] if line.split() else ""
        in_models = False
        for line in out.split("\n"):
            if line.startswith("---") and in_models:
                continue
            if "Model" in line and "Type" in line and "Device" in line:
                in_models = True
                continue
            if in_models and line.strip() and not line.startswith("-"):
                parts = line.split()
                if len(parts) >= 4:
                    result["models"].append({
                        "name": parts[0], "type": parts[1],
                        "device": parts[2], "recipe": parts[3],
                    })
        return result
    except Exception as e:
        return {"running": False, "error": str(e)}


def get_lemonade_backends():
    """Parse lemonade backends for installed/available backends."""
    try:
        r = subprocess.run(["lemonade", "backends"], capture_output=True, text=True, timeout=10)
        backends = []
        current_recipe = ""
        for line in r.stdout.split("\n"):
            if line.startswith("---") or not line.strip() or "Recipe" in line:
                continue
            parts = line.split()
            if not parts:
                continue
            if not line.startswith(" ") and not line.startswith("\t"):
                current_recipe = parts[0]
                parts = parts[1:]
            if len(parts) >= 2:
                backend = parts[0]
                status = parts[1]
                version = parts[2] if status == "installed" and len(parts) >= 3 else ""
                backends.append({
                    "recipe": current_recipe, "backend": backend,
                    "status": status, "version": version,
                })
        return {"backends": backends}
    except Exception as e:
        return {"backends": [], "error": str(e)}


def get_lemonade_models():
    """Parse lemonade list for model catalog."""
    try:
        r = subprocess.run(["lemonade", "list"], capture_output=True, text=True, timeout=15)
        models = []
        for line in r.stdout.split("\n"):
            if line.startswith("---") or not line.strip() or "Model Name" in line:
                continue
            name = line[:40].strip()
            rest = line[40:].strip()
            if not name:
                continue
            parts = rest.split()
            downloaded = parts[0] if parts else "No"
            recipe = parts[1] if len(parts) > 1 else ""
            if name and downloaded in ("Yes", "No"):
                models.append({"name": name, "downloaded": downloaded == "Yes", "recipe": recipe})
        return {"models": models}
    except Exception as e:
        return {"models": [], "error": str(e)}


def lemonade_load(model, backend="vulkan", ctx_size=4096):
    """Load a model with specified backend."""
    cmd = ["lemonade", "run", model, "--ctx-size", str(ctx_size)]
    if backend and backend != "default":
        cmd.extend(["--llamacpp", backend])
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
        return {"status": "ok" if r.returncode == 0 else "error",
                "output": (r.stdout + r.stderr)[:500]}
    except subprocess.TimeoutExpired:
        return {"status": "timeout", "output": "Model load timed out (120s)"}
    except Exception as e:
        return {"status": "error", "output": str(e)}


def lemonade_unload():
    """Unload all models."""
    try:
        r = subprocess.run(["lemonade", "unload"], capture_output=True, text=True, timeout=30)
        return {"status": "ok" if r.returncode == 0 else "error",
                "output": (r.stdout + r.stderr)[:500]}
    except Exception as e:
        return {"status": "error", "output": str(e)}


# ══════════════════════════════════════════════════════════════════
#  FLM NPU Models
# ══════════════════════════════════════════════════════════════════

def get_flm_models():
    """List FLM NPU models (installed + available)."""
    installed = []
    available = []
    try:
        r = subprocess.run(
            ["flm", "list", "--json", "--filter", "installed"],
            capture_output=True, text=True, timeout=10,
        )
        if r.returncode == 0 and r.stdout.strip():
            installed = json.loads(r.stdout)
    except Exception:
        pass
    try:
        r = subprocess.run(
            ["flm", "list", "--json"],
            capture_output=True, text=True, timeout=10,
        )
        if r.returncode == 0 and r.stdout.strip():
            available = json.loads(r.stdout)
    except Exception:
        pass
    return {"installed": installed, "available": available}


# ══════════════════════════════════════════════════════════════════
#  Nexus VPN Status
# ══════════════════════════════════════════════════════════════════

def nexus_status():
    """Get Nexus VPN service status, tunnel IP, and API health."""
    result = {"service": "inactive", "tunnel_ip": "—", "api_health": False, "ports": {
        "public": 9100, "private": 9101, "gossip": 9102, "wireguard": 51940
    }}
    result["service"] = run_cmd("systemctl is-active lemonade-nexus") or "inactive"
    # Tunnel IP from WireGuard
    wg_out = run_cmd("ip -4 addr show dev wg0 2>/dev/null")
    if wg_out:
        for line in wg_out.split("\n"):
            if "inet " in line:
                result["tunnel_ip"] = line.strip().split()[1].split("/")[0]
                break
    # API health
    try:
        import urllib.request
        with urllib.request.urlopen("http://127.0.0.1:9100/api/health", timeout=3) as resp:
            result["api_health"] = resp.status == 200
    except Exception:
        pass
    return result

def nexus_peers():
    """Get connected Nexus peers."""
    try:
        import urllib.request
        with urllib.request.urlopen("http://127.0.0.1:9100/api/peers", timeout=3) as resp:
            return json.loads(resp.read())
    except Exception:
        return {"peers": []}

def nexus_action(action):
    """Start/stop/restart Nexus service."""
    if action not in ("start", "stop", "restart"):
        return {"error": f"Invalid action: {action}"}
    run_cmd(f"sudo systemctl {action} lemonade-nexus", timeout=15)
    return {"action": action, "status": run_cmd("systemctl is-active lemonade-nexus")}


# ══════════════════════════════════════════════════════════════════
#  Btrfs Snapshots
# ══════════════════════════════════════════════════════════════════

def snapshot_list():
    """List btrfs snapshots."""
    try:
        r = subprocess.run(
            ["sudo", "btrfs", "subvolume", "list", "-s", "/"],
            capture_output=True, text=True, timeout=5,
        )
        snaps = []
        for line in r.stdout.strip().split("\n"):
            if not line.strip():
                continue
            parts = line.split()
            snap = {"raw": line.strip()}
            for i, p in enumerate(parts):
                if p == "path":
                    snap["path"] = " ".join(parts[i + 1:])
                elif p == "ID":
                    snap["id"] = parts[i + 1] if i + 1 < len(parts) else ""
            snaps.append(snap)
        return {"snapshots": snaps, "count": len(snaps)}
    except Exception as e:
        return {"snapshots": [], "error": str(e)}


def snapshot_create(name=""):
    """Create a btrfs snapshot."""
    tag = name or f"dashboard-{int(time.time())}"
    try:
        r = subprocess.run(
            ["sudo", "btrfs", "subvolume", "snapshot", "/", f"/.snapshots/{tag}"],
            capture_output=True, text=True, timeout=10,
        )
        return {"status": "created" if r.returncode == 0 else "failed",
                "name": tag, "output": r.stdout + r.stderr}
    except Exception as e:
        return {"status": "error", "error": str(e)}


# ══════════════════════════════════════════════════════════════════
#  LLM Live Stats
# ══════════════════════════════════════════════════════════════════

def get_llm_stats():
    """Get live LLM stats from Lemonade/llama.cpp."""
    global _last_llm_stats
    try:
        req = urllib.request.Request("http://127.0.0.1:13305/v1/models")
        with urllib.request.urlopen(req, timeout=3) as resp:
            models = json.loads(resp.read())
            if not models.get("data"):
                return {"model": "", "prompt_tps": 0, "gen_tps": 0, "ttft_ms": 0, "backend": "none"}
            model_name = models["data"][0].get("id", "")

        payload = json.dumps({
            "model": model_name,
            "messages": [{"role": "user", "content": "hi"}],
            "max_tokens": 1, "temperature": 0,
            "chat_template_kwargs": {"enable_thinking": False},
        }).encode()
        req = urllib.request.Request(
            "http://127.0.0.1:13305/v1/chat/completions",
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read())
            t = data.get("timings", {})
            _last_llm_stats = {
                "model": model_name,
                "prompt_tps": round(t.get("prompt_per_second", 0), 1),
                "gen_tps": round(t.get("predicted_per_second", 0), 1),
                "ttft_ms": round(t.get("prompt_ms", 0)),
                "gen_ms": round(t.get("predicted_ms", 0)),
                "backend": "vulkan",
            }
    except Exception as e:
        _last_llm_stats["error"] = str(e)[:100]
    return _last_llm_stats


# ══════════════════════════════════════════════════════════════════
#  Logs & Terminal
# ══════════════════════════════════════════════════════════════════

def get_logs():
    """Get recent journal logs for halo services."""
    lines = []
    try:
        result = subprocess.run(
            ["journalctl", "--user", "-n", "50", "--no-pager", "-o", "short-iso",
             "-u", "lemonade*", "-u", "halo-*", "-u", "gaia*", "-u", "caddy*", "-u", "kokoro*"],
            capture_output=True, text=True, timeout=5,
        )
        lines = result.stdout.strip().split("\n") if result.stdout.strip() else []
    except Exception:
        pass
    if not lines:
        try:
            result = subprocess.run(
                ["journalctl", "-n", "50", "--no-pager", "-o", "short-iso"],
                capture_output=True, text=True, timeout=5,
            )
            lines = result.stdout.strip().split("\n") if result.stdout.strip() else []
        except Exception:
            lines = ["[no journal access]"]
    return {"lines": lines[-50:]}


def run_safe_cmd(cmd):
    """Run read-only safe commands for the terminal."""
    if not cmd or not any(cmd.startswith(p) for p in SAFE_PREFIXES):
        return {"output": f"blocked: {cmd}\nonly read-only system commands allowed", "exit": 1}
    try:
        result = subprocess.run(
            shlex.split(cmd), capture_output=True, text=True, timeout=10,
        )
        output = result.stdout + result.stderr
        return {"output": output[-4000:], "exit": result.returncode}
    except Exception as e:
        return {"output": str(e), "exit": 1}


# ══════════════════════════════════════════════════════════════════
#  Software Versions
# ══════════════════════════════════════════════════════════════════

def get_software_versions():
    """Gather installed versions of all stack components."""
    def _run(cmd):
        try:
            r = subprocess.run(cmd, capture_output=True, text=True, timeout=5, shell=isinstance(cmd, str))
            return r.stdout.strip().split("\n")[0] if r.returncode == 0 else "n/a"
        except Exception:
            return "n/a"

    frozen = os.path.exists(FREEZE_FILE)
    wiki_base = "https://github.com/stampby/halo-ai-core/blob/main/docs/wiki"

    versions = {
        "kernel": {"version": _run(["uname", "-r"]), "wiki": f"{wiki_base}/Build-From-Source.md"},
        "rocm": {"version": "", "wiki": f"{wiki_base}/Components.md"},
        "lemonade": {"version": _run(["lemonade", "--version"]), "wiki": f"{wiki_base}/Model-Management.md"},
        "python": {"version": _run(["python3", "--version"]), "wiki": f"{wiki_base}/Adding-a-Service.md"},
        "caddy": {"version": _run(["caddy", "version"]), "wiki": f"{wiki_base}/Caddy-Routing.md"},
    }
    try:
        with open("/opt/rocm/.info/version") as f:
            versions["rocm"]["version"] = f.read().strip()
    except Exception:
        versions["rocm"]["version"] = "n/a"

    try:
        be = get_lemonade_backends()
        for b in be.get("backends", []):
            if b["recipe"] == "llamacpp" and b["status"] == "installed":
                versions[f"llamacpp_{b['backend']}"] = {
                    "version": b["version"] or "installed",
                    "wiki": f"{wiki_base}/Benchmarks.md",
                }
    except Exception:
        pass

    return {"versions": versions, "frozen": frozen}


# ══════════════════════════════════════════════════════════════════
#  HTTP Server
# ══════════════════════════════════════════════════════════════════

# Cache static hardware info at startup
HW_INFO = get_hw_info()


class UnifiedHandler(BaseHTTPRequestHandler):
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
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path
        qs = urllib.parse.parse_qs(parsed.query)

        # ── Frontend ──
        if path in ("/", "/packages"):
            self._html(HALO_ROOT / "dashboard" / "packages.html")

        # ── Package Management ──
        elif path == "/api/packages":
            self._json(get_all_packages())
        elif path == "/api/summary":
            self._json(get_system_summary())
        elif path.startswith("/api/package/"):
            name = path.split("/")[-1]
            if name in REGISTRY:
                self._json(get_package_state(name, REGISTRY[name]))
            else:
                self._json({"error": "Package not found"}, 404)

        # ── Hardware Stats ──
        elif path == "/api/stats":
            self._json(get_live_stats())
        elif path == "/api/hw":
            self._json(HW_INFO)

        # ── Models ──
        elif path == "/api/models":
            self._json(get_lemonade_models())
        elif path == "/api/models/flm":
            self._json(get_flm_models())

        # ── Lemonade Control ──
        elif path == "/api/lemonade/status":
            self._json(get_lemonade_status())
        elif path == "/api/lemonade/backends":
            self._json(get_lemonade_backends())

        # ── Nexus VPN ──
        elif path == "/api/nexus/status":
            self._json(nexus_status())
        elif path == "/api/nexus/peers":
            self._json(nexus_peers())

        # ── Snapshots ──
        elif path == "/api/snapshots":
            self._json(snapshot_list())

        # ── LLM Stats ──
        elif path == "/api/llm/stats":
            self._json(get_llm_stats())

        # ── Logs ──
        elif path == "/api/logs":
            self._json(get_logs())

        # ── Software Versions ──
        elif path == "/api/software/versions":
            self._json(get_software_versions())

        # ── Safe Terminal ──
        elif path == "/exec":
            cmd = qs.get("cmd", [""])[0]
            self._json(run_safe_cmd(cmd))

        else:
            self.send_error(404)

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(length)) if length else {}
        parsed = urllib.parse.urlparse(self.path)
        path = parsed.path

        if path == "/api/service":
            svc = body.get("service")
            action = body.get("action")
            self._json(service_action(svc, action))

        elif path == "/api/build":
            name = body.get("package")
            if name in REGISTRY and REGISTRY[name].get("build_cmd"):
                cmd = REGISTRY[name]["build_cmd"]
                log_file = LOG_DIR / f"build-{name}.log"
                LOG_DIR.mkdir(parents=True, exist_ok=True)
                subprocess.Popen(f"({cmd}) > {log_file} 2>&1", shell=True)
                self._json({"package": name, "status": "building", "log": str(log_file)})
            else:
                self._json({"error": "No build command"}, 400)

        elif path == "/api/lemonade/load":
            self._json(lemonade_load(
                body.get("model", ""),
                body.get("backend", "vulkan"),
                body.get("ctx_size", 4096),
            ))

        elif path == "/api/lemonade/unload":
            self._json(lemonade_unload())

        elif path == "/api/snapshots/create":
            self._json(snapshot_create(body.get("name", "")))

        elif path in ("/api/nexus/start", "/api/nexus/stop", "/api/nexus/restart"):
            action = path.split("/")[-1]
            self._json(nexus_action(action))

        else:
            self.send_error(404)


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 3010
    server = HTTPServer(("127.0.0.1", port), UnifiedHandler)
    signal.signal(signal.SIGINT, lambda *_: sys.exit(0))
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    print(f"[pkg-manager] Unified server on http://127.0.0.1:{port}")
    server.serve_forever()


if __name__ == "__main__":
    main()
