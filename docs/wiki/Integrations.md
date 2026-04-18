# Integrations

**One endpoint does it all.** The 1-bit monster speaks the OpenAI HTTP schema.
Any tool, IDE extension, CLI, or paid desktop app that supports a configurable
OpenAI base URL works against it with zero adapter code.

Full working code examples — curl, Python, Node, C++, SSE streaming, voice
loops — live in **[docs/INTEGRATIONS.md](../INTEGRATIONS.md)**. Private-mesh /
multi-device onboarding (phone, laptop, game PC, other halo boxes) is in
**[NETWORKING.md](../NETWORKING.md)**. This page is the quick orientation.

## Endpoints

| scope | URL | port | notes |
|---|---|---|---|
| on the halo box | `http://127.0.0.1:8080/v1` | 8080 | OpenAI-compat + SSE; no auth |
| from another mesh peer | `https://<halo-hostname>.local/v1` | 443 | Caddy + bearer token |
| mesh peer, direct | `http://<tailnet-ip>:8080/v1` | 8080 | straight to bitnet_decode over WireGuard |

Secondary (optional) endpoints for voice workflows:

| what | port | protocol |
|---|---|---|
| `whisper-server` | 8082 | multipart POST /transcribe (speech-to-text) |
| `kokoro-tts` | 5000 | JSON POST /tts → WAV (text-to-speech) |

Only Caddy (:443) and the Headscale/Tailscale daemons are exposed to the LAN.
Everything else binds to `127.0.0.1` or the tailnet interface — the "opt-in" for
network exposure is joining the Headscale mesh, not opening a port on your WAN.

## Point the apps you already pay for at it

### Claude Code (Anthropic CLI)
```fish
set -x OPENAI_API_BASE http://127.0.0.1:8080/v1
set -x OPENAI_API_KEY  halo-local
claude --model bitnet-b1.58-2b-4t
```

### Claude Desktop
Settings → Custom API endpoint → `http://127.0.0.1:8080/v1`, model
`bitnet-b1.58-2b-4t`, any non-empty key.

### Cursor
Settings → Models → Add Custom Model → base URL `http://127.0.0.1:8080/v1`,
model `bitnet-b1.58-2b-4t`, enable "Override OpenAI Base URL."

### Continue.dev (VS Code / JetBrains)
```json
{"models":[{"title":"halo-ai","provider":"openai","model":"bitnet-b1.58-2b-4t",
 "apiBase":"http://127.0.0.1:8080/v1","apiKey":"halo-local"}]}
```

### Open WebUI, LibreChat, Aider, Jan, LM Studio
All support a custom OpenAI base URL. Same endpoint, same model id, any key.

## Quick curl

```bash
curl http://127.0.0.1:8080/v1/chat/completions \
  -H 'content-type: application/json' \
  -d '{"model":"bitnet-b1.58-2b-4t","messages":[{"role":"user","content":"hi"}]}'
```

## Exposing to another device

- **SSH tunnel** (simplest): `ssh -L 8080:127.0.0.1:8080 strixhalo`
- **caddy reverse proxy** with bearer auth — template in `orchestrator/`
- **WireGuard / Tailscale** — rebind services to the VPN interface

## Philosophy

Nothing in this stack phones home. Your prompts, audio, transcripts, replies —
none of it leaves the box unless you explicitly make it leave. Paid API keys
(OpenAI, Anthropic, Groq, DeepSeek, xAI, OpenRouter) are an *opt-in* routing
feature through the `sommelier` specialist, not a default.

→ **[Read the full integrations doc](../INTEGRATIONS.md)** for working code.
