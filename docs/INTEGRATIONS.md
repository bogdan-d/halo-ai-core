# Integrating your apps with halo-ai-core

**One endpoint does it all.** The 1-bit monster speaks OpenAI's HTTP schema. Any tool,
library, IDE extension, or paid desktop app that supports an OpenAI-compatible base URL
works against it with zero adapter code.

> **Runs on CachyOS.** The XDNA2 NPU path needs the `amdxdna` patches that
> CachyOS carries out of the box. Other distros silently fall back to the
> iGPU; see the warning at the top of the [main README](../README.md).

After `install-strixhalo.sh` runs you have two equivalent endpoints — pick the one that
matches where the client is:

| scope | base URL | API key |
|---|---|---|
| **on the halo box itself** | `http://127.0.0.1:8080/v1` | anything non-empty |
| **from another device on the private mesh** (Headscale) | `https://<halo-hostname>.local/v1` *or* `http://<tailnet-ip>:8080/v1` | bearer token printed by the installer (also at `/etc/caddy/token.secret`) |

Joining a device to the mesh is a one-liner (Arch-family) or a QR scan (phone) — see
**[NETWORKING.md](NETWORKING.md)** for the walkthrough. The rest of this doc assumes
you already have an endpoint + key.

Two secondary endpoints exist for voice workflows (optional, off by default):

| endpoint | port | what it is |
|---|---|---|
| `bitnet_decode --server` | **8080** | chat completions + model list (OpenAI-compat) — *this is the one* |
| `whisper-server`         | **8082** | speech → text (multipart POST) |
| `kokoro-tts`             | **5000** | text → speech (JSON POST → WAV bytes) |

## 1. Chat / LLM (bitnet_decode on :8080)

**Start it** (already running if you used `install-strixhalo.sh`):
```bash
systemctl --user status halo-bitnet   # or
bitnet_decode /home/bcloud/halo-ai/models/halo-1bit-2b.h1b --server 8080
```

### curl

```bash
# List available models
curl http://127.0.0.1:8080/v1/models

# Chat completion (non-streaming)
curl http://127.0.0.1:8080/v1/chat/completions \
  -H 'content-type: application/json' \
  -d '{
    "model": "bitnet-b1.58-2b-4t",
    "messages": [{"role":"user","content":"write a haiku about strix halo"}],
    "max_tokens": 64,
    "temperature": 0.7
  }'

# Chat completion (SSE streaming)
curl -N http://127.0.0.1:8080/v1/chat/completions \
  -H 'content-type: application/json' \
  -d '{
    "model": "bitnet-b1.58-2b-4t",
    "messages": [{"role":"user","content":"count to ten"}],
    "stream": true
  }'
```

### Python (openai SDK)

```python
from openai import OpenAI
client = OpenAI(
    base_url="http://127.0.0.1:8080/v1",
    api_key="not-needed",              # server ignores it; pass any non-empty string
)

r = client.chat.completions.create(
    model="bitnet-b1.58-2b-4t",
    messages=[{"role": "user", "content": "hi"}],
    max_tokens=64,
)
print(r.choices[0].message.content)

# Streaming
for chunk in client.chat.completions.create(
    model="bitnet-b1.58-2b-4t",
    messages=[{"role": "user", "content": "count to ten"}],
    stream=True,
):
    print(chunk.choices[0].delta.content or "", end="", flush=True)
```

### Node.js (openai SDK)

```js
import OpenAI from "openai";
const client = new OpenAI({
  baseURL: "http://127.0.0.1:8080/v1",
  apiKey: "not-needed",
});

const r = await client.chat.completions.create({
  model: "bitnet-b1.58-2b-4t",
  messages: [{ role: "user", content: "hi" }],
});
console.log(r.choices[0].message.content);
```

### C++ (httplib)

```cpp
#include <httplib.h>
#include <nlohmann/json.hpp>
using json = nlohmann::json;

httplib::Client cli("127.0.0.1", 8080);
json body = {
    {"model", "bitnet-b1.58-2b-4t"},
    {"messages", json::array({{{"role","user"},{"content","hi"}}})},
    {"max_tokens", 64},
};
auto res = cli.Post("/v1/chat/completions",
                    {{"Content-Type","application/json"}},
                    body.dump(), "application/json");
auto reply = json::parse(res->body);
std::cout << reply["choices"][0]["message"]["content"].get<std::string>();
```

### Plug it into the apps you already pay for

Any client that exposes a configurable OpenAI base URL works. One line of
config each. You keep the polished UI, we supply the inference.

#### Claude Code (Anthropic CLI)

Claude Code speaks the OpenAI schema when you point it at a custom base URL.
Export two env vars before you launch it — or put them in `~/.config/fish/config.fish`:

```fish
set -x OPENAI_API_BASE http://127.0.0.1:8080/v1
set -x OPENAI_API_KEY  halo-local
```

Then `claude --model bitnet-b1.58-2b-4t` routes every token through your box.

#### Claude Desktop (macOS / Windows / Linux AppImage)

Settings → "Custom API endpoint" → `http://127.0.0.1:8080/v1`. Model name
`bitnet-b1.58-2b-4t`. API key: any non-empty string. Desktop keeps all its
Projects + Artifacts UX — only the inference moves local.

#### Cursor (VS Code fork)

Settings → Models → "Add Custom Model" → set base URL to
`http://127.0.0.1:8080/v1`, model `bitnet-b1.58-2b-4t`, enable "Override OpenAI
Base URL." Cursor Chat, Edit, and Tab all work against the local server.

#### Continue.dev (VS Code, JetBrains)

`~/.continue/config.json`:
```json
{
  "models": [{
    "title": "halo-ai (local)",
    "provider": "openai",
    "model": "bitnet-b1.58-2b-4t",
    "apiBase": "http://127.0.0.1:8080/v1",
    "apiKey": "halo-local"
  }]
}
```

#### Open WebUI

Admin → Settings → Connections → add an OpenAI endpoint with base URL
`http://127.0.0.1:8080/v1`, any API key. Model shows up in the picker as
`bitnet-b1.58-2b-4t`.

#### Aider, LibreChat, Chatbot UI, Jan, LM Studio

- **Aider** — `aider --openai-api-base http://127.0.0.1:8080/v1 --model bitnet-b1.58-2b-4t`
- **LibreChat** — set `OPENAI_REVERSE_PROXY=http://127.0.0.1:8080/v1` in `.env`.
- **Chatbot UI** — base URL in Settings.
- **Jan / LM Studio** — add a remote OpenAI-compatible server at `:8080`.

Nothing in the list above is a hack: they all already support a user-supplied
base URL. halo-ai-core is just another OpenAI server to them.

## 2. Speech-to-text (whisper-server on :8082)

```bash
# POST multipart. 'audio' field = WAV/FLAC/MP3 file.
curl -X POST http://127.0.0.1:8082/transcribe \
  -F audio=@recording.wav \
  -F language=en
# → {"text": "hello world", "language": "en"}
```

### Python

```python
import requests
with open("recording.wav", "rb") as f:
    r = requests.post(
        "http://127.0.0.1:8082/transcribe",
        files={"audio": f},
        data={"language": "en"},
    )
print(r.json()["text"])
```

## 3. Text-to-speech (kokoro-tts on :5000)

```bash
curl -X POST http://127.0.0.1:5000/tts \
  -H 'content-type: application/json' \
  -d '{"text":"the 1-bit monster is awake","voice":"af_heart"}' \
  -o out.wav
# → 24 kHz 16-bit mono WAV
```

### Python

```python
import requests
r = requests.post(
    "http://127.0.0.1:5000/tts",
    json={"text": "the 1-bit monster is awake", "voice": "af_heart"},
)
open("out.wav", "wb").write(r.content)
```

Available voices: `af_heart` (default), plus the standard Kokoro voice bank. See
[Kokoro-FastAPI docs](https://github.com/remsky/Kokoro-FastAPI).

## 4. Voice loop (STT → LLM → TTS)

Tie it together in 20 lines of Python:

```python
import requests
from openai import OpenAI

llm = OpenAI(base_url="http://127.0.0.1:8080/v1", api_key="x")

def speak_listen_reply(wav_path):
    # 1. transcribe
    with open(wav_path, "rb") as f:
        text = requests.post("http://127.0.0.1:8082/transcribe",
            files={"audio": f}, data={"language": "en"}).json()["text"]
    print(f"user: {text}")

    # 2. LLM response
    reply = llm.chat.completions.create(
        model="bitnet-b1.58-2b-4t",
        messages=[{"role": "user", "content": text}],
        max_tokens=128,
    ).choices[0].message.content
    print(f"halo: {reply}")

    # 3. synthesize
    audio = requests.post("http://127.0.0.1:5000/tts",
        json={"text": reply, "voice": "af_heart"}).content
    open("reply.wav", "wb").write(audio)
    return reply

speak_listen_reply("recording.wav")
```

## 5. Exposing the stack to your phone / tablet / LAN

The services bind to `127.0.0.1` only by default (privacy-first). Reach them
from another device via the private mesh `install-strixhalo.sh` stood up:

### Option A (default): the private Headscale mesh

The installer stood up Caddy + Headscale and printed a QR code + a one-liner
at the end. Any peer joins with:

```bash
# Arch-family (laptop, other halo box):
curl -fsSL http://<halo-lan-ip>:8099/join.sh | sudo bash

# Phone (iOS / Android): scan the QR code, follow the 3-step mobile page.

# Other Linux / macOS: install Tailscale, set the alternate login server
# to https://headscale.<halo-hostname>.local, paste the preauth key.
```

Once joined, your OpenAI-compatible client points at
`https://<halo-hostname>.local/v1` with the bearer token from
`/etc/caddy/token.secret` (or the installer output). Full walkthrough in
**[NETWORKING.md](NETWORKING.md)**.

### Option B: SSH tunnel (zero-config, single peer)

If you don't want the mesh running:

```bash
# From your laptop/phone:
ssh -L 8080:127.0.0.1:8080 \
    -L 8082:127.0.0.1:8082 \
    -L 5000:127.0.0.1:5000 \
    <your-strixhalo-box>
# Now apps on your laptop point at http://127.0.0.1:8080 and talk to the stack
```

### Option C: bind to the tailnet interface directly

Skip the Caddy reverse proxy and have the services listen on the WireGuard
interface. Edit the systemd unit's `ExecStart` to pass the tailnet IP
(`100.64.0.1` on the strixhalo box by default). Peers reach it at
`http://<tailnet-ip>:8080/v1` with no TLS / no bearer auth — only trust
this if you trust every mesh member.

## 6. Listing running backends (sommelier)

If you're running `agent_cpp` with API keys set (`AGENT_CPP_OPENAI_API_KEY`,
etc.), sommelier routes between local and paid backends. Query available
backends via the agent bus:

```bash
echo "backends" | agent_cpp 2>&1 | grep backends_list
```

In future: an HTTP endpoint on agent_cpp itself for this. For now it's a
stdin-dispatched query.

## 7. Agent-cpp bus messages (advanced)

`agent_cpp` is the 17-specialist runtime. You don't usually talk to it from apps
directly — it's the internal conductor. But if you want to fire events into it
from outside:

- **Discord events** (if sentinel is watching a channel) → `discord_message` kind
- **GitHub webhook → anvil** (for triggered builds) → `bench_run_request` kind
- **Install log** → carpenter → `install_log` kind

Each specialist's contract is documented at the top of its `.cpp` file:
[agent-cpp/specialists/*.cpp](https://github.com/stampby/agent-cpp/tree/main/specialists).

---

## Troubleshooting

**`connection refused` on :8080** — `halo-bitnet.service` not running.
`systemctl --user start halo-bitnet` or `sudo systemctl start halo-bitnet`.

**Empty response / 500** — check model path. The installed location is
`~/halo-ai/models/halo-1bit-2b.h1b`; the systemd unit points at it directly.

**Slow first token** — cold cache. First request mmaps the ~1.1 GiB model
(TQ1_0 .h1b) into GPU-visible memory. Cold start < 2s; subsequent requests
hit ~83 tok/s @ 64 ctx (68.6 @ 1024) steady-state.

**`model not found`** — the model id is `bitnet-b1.58-2b-4t`. Pass any other
string and the server rejects the request.

## Philosophy of local

Nothing in this file phones home. Every endpoint listed binds to `127.0.0.1`
unless you explicitly rebind it. Your prompts, your audio, your transcripts,
your replies — they never leave your machine unless YOU make them leave.

Paid API keys (OpenAI, Anthropic, Groq, DeepSeek, xAI, OpenRouter) are an
opt-in routing feature through sommelier, not a default. Local first means
local first.

*"there is no cloud. there is only zuul."*
