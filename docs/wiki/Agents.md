# Agents — the 17 C++ specialists

`agent-cpp` ships one runtime binary (`agent_cpp`, ~1.3 MB) that registers 17
single-purpose specialists on a shared message bus. One job per specialist,
one thread per inbox, one structured `Message` struct.

## Quick reference

| # | name | one-line job | external dep |
|--|---|---|---|
| 1 | **muse** | LLM chat via sommelier | rocm-cpp server |
| 2 | **planner** | ReAct-style goal → plan reasoner | rocm-cpp server |
| 3 | **forge** | tool dispatcher (runs approved tools) | — |
| 4 | **warden** | CVG 4-check gate on tool calls | — |
| 5 | **cartograph** | memory (keyword + usearch v2) | — |
| 6 | **scribe** | hash-chained JSONL session log | OpenSSL |
| 7 | **sommelier** | LLM backend routing (local + 5 paid) | rocm-cpp + optional API keys |
| 8 | **stdout_sink** | terminal relay for debug | — |
| 9 | **herald** | Discord poster (write side, REST) | DISCORD_TOKEN |
| 10 | **sentinel** | Discord channel watcher (read side, poll) | DISCORD_TOKEN |
| 11 | **carpenter** | install-help via regex + LLM fallback | AGENT_CPP_INSTALL_HELP_CHANNEL |
| 12 | **quartermaster** | GitHub issue triage + labelling | GH_TOKEN |
| 13 | **magistrate** | GitHub PR policy scanner | GH_TOKEN |
| 14 | **librarian** | CHANGELOG appender + docs-gap issue | GH_TOKEN |
| 15 | **echo_ear** | whisper-server STT bridge | whisper-server :8082 |
| 16 | **echo_mouth** | kokoro TTS bridge | kokoro-tts :5000 |
| 17 | **anvil** | clone → build → bench runner | GH_TOKEN + DISCORD_BENCH_CHANNEL |

## How to wire each one

Every specialist degrades cleanly when its dependency is absent. Unset tokens →
warn-once-on-start, skip the work. No crashes, no cascading failures.

### Discord

```bash
export DISCORD_TOKEN="..."                          # bot token (starts with Bot or MTA...)
export DISCORD_WATCH_CHANNELS="123,456,789"         # sentinel polls these
export DISCORD_ESCALATION_CHANNEL="111"             # critical issue pings go here
export DISCORD_ANNOUNCEMENTS_CHANNEL="222"          # librarian posts releases here
export DISCORD_BENCH_CHANNEL="333"                  # anvil posts bench headlines here
export AGENT_CPP_INSTALL_HELP_CHANNEL="444"         # carpenter auto-replies here
```

### GitHub

```bash
export GH_TOKEN="ghp_..."                            # classic PAT with repo scope
```

### Voice

Both local services. If systemd units installed:
```bash
systemctl --user start whisper-server
systemctl --user start kokoro-tts
```
Then set overrides only if non-default ports:
```bash
export WHISPER_URL="http://127.0.0.1:8082"
export KOKORO_URL="http://127.0.0.1:5000"
export KOKORO_VOICE="af_heart"
```

### Paid LLM backends (sommelier routing)

```bash
export AGENT_CPP_OPENAI_API_KEY="sk-..."
export AGENT_CPP_GROQ_API_KEY="..."
export AGENT_CPP_DEEPSEEK_API_KEY="..."
export AGENT_CPP_XAI_API_KEY="..."
export AGENT_CPP_OPENROUTER_API_KEY="..."
```

## Message kinds (selected)

Each specialist publishes what it accepts and emits at the top of its `.cpp` file.
Common ones:

| kind | from → to | what it carries |
|---|---|---|
| `user_said` | stdout → muse | interactive chat input |
| `muse_reply` | muse → stdout | LLM response text |
| `user_goal` | stdout → planner | "plan: <text>" prefix |
| `tool_call` | anywhere → forge | {tool, args, reason} |
| `exec_request` | forge → warden | same payload, CVG review |
| `exec_allow` / `exec_deny` | warden → forge | gate decision |
| `tool_result` | forge → src | {ok, data} or {error} |
| `discord_message` | sentinel → broadcast | channel events |
| `discord_post` | anywhere → herald | post to a channel |
| `decode_request` | anywhere → sommelier | LLM query with hint |
| `decode_result` | sommelier → src | chat completion result |
| `remember` / `recall` | anywhere → cartograph | memory operations |
| `bench_run_request` | anywhere → anvil | clone+build+bench a repo |

Everything on the bus also flows to **scribe** as a side-effect (hash-chained
JSONL at `$XDG_STATE_HOME/agent-cpp/sessions/YYYYMMDD-HHMMSS.jsonl`).

## CVG gate (warden)

The warden specialist implements a 4-check structural gate on every tool call:

| # | check | deny code | fail reason |
|---|---|---|---|
| 1 | **policy** | 1 | tool name not on allow-list |
| 2 | **intent** | 2 | caller didn't articulate a `reason` |
| 3 | **consent** | 3 | lockfile at `$XDG_CONFIG_HOME/agent-cpp/locked` exists |
| 4 | **bounds** | 4 | arg-shape violation (e.g. echo text > 4096 bytes) |

First failing check short-circuits. This is **structural**, not advisory — no
way to bypass without editing the source. The audit log records every denial.

Inspired by Edwards 2026 (Convergence Point Theory): ConsentVerificationGate.

## Hash-chained audit log (scribe)

Every message routed on the bus is copied to `scribe`, which serializes:

```json
{"prev": "<hash of previous line>",
 "hash": "<SHA256(prev + this body)>",
 "body": {"ts": ..., "id": ..., "from": ..., "to": ..., "kind": ..., "payload": ...}}
```

Tamper with any past line and every downstream `prev` fails to match. Cheap
tamper-evidence, no external store. Genesis line seeds from session path + time.

## Headless vs interactive

- **Interactive** (stdin is a tty): banner + dispatch table, commands like
  `plan: build rocm-cpp` or `tool: echo text=hi` or `discord: <id> hello`
- **Headless** (stdin is `/dev/null` or `AGENT_CPP_HEADLESS=1`): skip the
  stdin loop entirely, bus runs until SIGTERM. Used by `halo-agent.service`.

Auto-detected via `isatty(STDIN_FILENO)`.

## Adding a new specialist

~40 lines of C++:

```cpp
// specialists/my_thing.cpp
#include "agents/agent.h"
#include "agents/runtime.h"
#include <memory>

namespace rocm_cpp::agents::specialists {
class MyThing : public Agent {
public:
    const std::string& name() const override { return name_; }
    void handle(const Message& msg, Runtime& rt) override {
        if (msg.kind != "my_kind") return;
        // ... do the thing ...
        rt.send({.from=name_, .to=msg.from, .kind="my_reply", .payload="ok"});
    }
private:
    std::string name_ = "my_thing";
};
std::unique_ptr<Agent> make_my_thing() { return std::make_unique<MyThing>(); }
}
```

Then add one line to `CMakeLists.txt` (under `specialists/`) and two lines to
`src/main.cpp` (forward decl + `rt.register_agent(make_my_thing());`). Rebuild.
