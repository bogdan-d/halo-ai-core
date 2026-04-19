# Getting Started

Zero to a running inference server in ~5 minutes on Strix Halo, ~4 hours on
anything else that needs building from source.

## 1. Prerequisites

- **Hardware**: AMD Strix Halo (Radeon 8060S, gfx1151) — or any Ryzen AI APU /
  RDNA3+ dGPU if you're on the source path
- **OS**: **CachyOS**. This is not optional for the NPU path — the XDNA2 NPU
  on Strix Halo only works correctly on CachyOS. Stock Arch, Ubuntu, Fedora,
  EndeavourOS, Manjaro either miss the NPU patches or silently fall back to
  CPU. See the CachyOS gate in the main README for details.
- **Privileges**: passwordless `sudo` for the installer
- **Disk**: ~20 GiB free (build artifacts, kernels, models)

## 2. Install

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install.sh           # auto-detects your GPU and picks the right path
```

`install.sh` dispatches to one of two paths:

| your GPU | path | time |
|---|---|---|
| **gfx1151** (Strix Halo) | `install-strixhalo.sh` — downloads pre-built binaries | ~5 min |
| anything else | `install-source.sh` — builds TheRock + rocm-cpp + agent-cpp from source | ~4 hrs |

Force either explicitly: `./install.sh --strixhalo` or `./install.sh --source`.

## 3. Verify

After install, the halo services run under **user-systemd** (since 2026-04-19
migration). Two are core; three more are optional:

```bash
# Core
systemctl --user status halo-bitnet    # LLM inference server (:8080)
systemctl --user status halo-agent     # 17-specialist agent runtime

# Optional (voice + image)
systemctl --user status halo-sd        # native HIP SDXL (:8081, Caddy /sd/*)
systemctl --user status halo-whisper   # whisper.cpp STT (:8082, echo_ear)
systemctl --user status halo-kokoro    # Bun Kokoro TTS shim (:8083, echo_mouth)

# Smoke test
curl http://127.0.0.1:8080/v1/models
# → {"data":[{"id":"bitnet-b1.58-2b-4t","object":"model","owned_by":"halo-ai"}],...}

# One-shot health probe for the whole stack
halo doctor
```

`halo` is the unified ops CLI (see [docs/halo-cli.md](../halo-cli.md)); pacman +
brew + systemctl pattern. `halo status`, `halo logs bitnet -f`, `halo restart sd`,
`halo bench`, `halo update`.

## 4. First chat completion

```bash
curl http://127.0.0.1:8080/v1/chat/completions \
  -H 'content-type: application/json' \
  -d '{
    "model": "bitnet-b1.58-2b-4t",
    "messages": [{"role":"user","content":"say hi in 5 words"}],
    "max_tokens": 32
  }'
```

Expected: <2 s cold start, **83 tok/s @ 64 ctx / 68.6 tok/s @ 1024 ctx** greedy
decode (post-RoPE-fix + split-KV FD default), PPL 9.16 on wikitext-103 (1k
window) — matching the BitNet-b1.58-2B-4T paper baseline.

## 5. Point your apps at it

See the [Integrations](Integrations.md) page. Short version: any OpenAI-compat
client works against `http://127.0.0.1:8080/v1` with any non-empty API key —
or, from another device on the mesh, against `https://<halo-hostname>.local/v1`
with the bearer token the installer printed.

## 6. Add other devices to the private mesh

`install-strixhalo.sh` stood up a **Headscale** coordination server on the halo
box and printed a QR code + one-liner at the end. Rerun the installer if you
missed it (idempotent), or pull the onboarding bits directly:

| device type | how |
|---|---|
| another Arch-family box (laptop, other halo) | `curl -fsSL http://<halo-lan-ip>:8099/join.sh \| sudo bash` |
| phone (iOS / Android) | scan the QR → follow the mobile onboarding page |
| Windows / Mac / Ubuntu / Fedora | install Tailscale, point at `https://headscale.<halo-hostname>.local`, paste the preauth key |

The mesh is **bi-directional full-mesh WireGuard** — any peer reaches any
other peer. Full walkthrough: [Networking](../NETWORKING.md).

Once joined, your OpenAI-compatible app (Chatbox, LM Studio, SillyTavern,
Continue, Jan, etc.) talks to `https://<halo-hostname>.local/v1` with the
printed bearer token. Zero port forwarding, zero cloud.

## 7. What's next

- **Voice loop**: `systemctl --user start halo-whisper halo-kokoro`, then
  see the STT→LLM→TTS example in [Integrations](Integrations.md).
- **Image gen**: `systemctl --user start halo-sd` (native-HIP SDXL on :8081,
  exposed through Caddy at `/sd/*`).
- **Agent specialists**: `agent_cpp` is running in headless mode. To connect
  Discord, set `DISCORD_TOKEN` + `DISCORD_WATCH_CHANNELS` in the service
  environment. See [Agents](Agents.md).
- **MCP bridge**: `halo-mcp` exposes the 17 specialists as JSON-RPC tools for
  Claude Code (Phase 0 stubs live; BusBridge pending). See
  [docs/mcp-nexus-design.md](../mcp-nexus-design.md).

## Uninstall

The unified script handles every component installed by the monolith:

```bash
cd ~/halo-ai-core
./uninstall.sh                  # interactive — confirms each block
./uninstall.sh --yes-all        # non-interactive
```

That's it. No system-wide state outside what the script cleans.
