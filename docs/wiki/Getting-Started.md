# Getting Started

Zero to a running inference server in ~5 minutes on Strix Halo, ~4 hours on
anything else that needs building from source.

## 1. Prerequisites

- **Hardware**: AMD Strix Halo (Radeon 8060S, gfx1151) — or any Ryzen AI APU /
  RDNA3+ dGPU if you're on the source path
- **OS**: Arch Linux (CachyOS works too). Bare metal recommended; podman works
  for headless setups.
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

After install, two systemd services should be running:

```bash
systemctl status halo-bitnet     # the inference server
systemctl status halo-agent      # the 17-specialist agent runtime

# Smoke test
curl http://127.0.0.1:8080/v1/models
# → {"data":[{"id":"bitnet-b1.58-2b-4t","object":"model","owned_by":"halo-ai"}],...}
```

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

Expected: ~300 ms round-trip, ~85 tok/s decode steady-state.

## 5. Point your apps at it

See the [Integrations](Integrations.md) page. Short version: any OpenAI-compat
client works against `http://127.0.0.1:8080/v1` with any non-empty API key.

## 6. What's next

- **Voice loop**: start `whisper-server` and `kokoro-tts` systemd units, then
  see the STT→LLM→TTS example in [Integrations](Integrations.md).
- **Agent specialists**: `agent_cpp` is running in headless mode. To connect
  Discord, set `DISCORD_TOKEN` + `DISCORD_WATCH_CHANNELS` in the service
  environment. See [Agents](Agents.md).
- **Expose to LAN/phone**: SSH tunnel or caddy reverse proxy with bearer auth
  — both covered in [Integrations](Integrations.md).

## Uninstall

```bash
sudo systemctl disable --now halo-bitnet halo-agent
sudo rm /etc/systemd/system/halo-bitnet.service /etc/systemd/system/halo-agent.service
sudo rm /usr/local/bin/{bitnet_decode,agent_cpp} /usr/local/lib/librocm_cpp.so
rm -rf ~/halo-ai
```

That's it. No system-wide state outside those paths.
