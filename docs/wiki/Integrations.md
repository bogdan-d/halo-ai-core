# Integrations

Full integration examples — curl, Python, Node, C++, WebUI frontends,
voice loops, LAN exposure — live in **[docs/INTEGRATIONS.md](../INTEGRATIONS.md)**.

This page is a short summary for quick orientation. For working code, go to
the full doc.

## Endpoints at a glance

| what | port | protocol | example client |
|---|---|---|---|
| `bitnet_decode --server` | 8080 | OpenAI-compat HTTP + SSE | openai SDK, any WebUI |
| `whisper-server` | 8082 | multipart POST /transcribe | curl, requests |
| `kokoro-tts` | 5000 | JSON POST /tts → WAV | curl, requests |

All bind to `127.0.0.1` by default.

## OpenAI SDK (Python)

```python
from openai import OpenAI
client = OpenAI(base_url="http://127.0.0.1:8080/v1", api_key="x")
print(client.chat.completions.create(
    model="bitnet-b1.58-2b-4t",
    messages=[{"role":"user","content":"hi"}],
).choices[0].message.content)
```

## WebUI frontends (tested)

- Open WebUI, LibreChat, Chatbot UI, Continue.dev, Aider

## Exposing to another device

- **SSH tunnel** (simplest, zero config): `ssh -L 8080:127.0.0.1:8080 strixhalo`
- **caddy reverse proxy** with bearer auth (template in orchestrator/)
- **WireGuard / Tailscale** — rebind services to the VPN interface

## Philosophy

Nothing in this stack phones home. Your prompts, audio, transcripts, replies —
none of it leaves the box unless you explicitly make it leave.

→ **[Read the full integrations doc](../INTEGRATIONS.md)** for working code.
