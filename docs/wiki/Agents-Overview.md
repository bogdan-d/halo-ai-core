# Agents Overview

Halo AI uses 17 LLM-powered agents. Each agent has a name, a backstory, a voice, and a specific role. They're not just scripts — they're characters that interact with each other and with users.

> *"They're LLM actors — real voice clones, pluggable."*

## Core Agents

| Agent | Role | Personality |
|-------|------|-------------|
| **Amp** | Audio engineer | Quiet, precise, lives in the waveform |
| **Bounty** | Support & community | Friendly, helpful, auto-creates threads |
| **Conductor** | Orchestrator | Coordinates other agents, big picture |
| **Dealer** | Content distribution | Gets the word out, handles releases |
| **Forge** | Builder | Writes code, builds features |
| **Interpreter** | Translation | Multilingual, handles localization |
| **Sentinel** | Security | Watches everything, trusts nothing |
| **Architect** | The boss | System design, final say |

## Support Agents

| Agent | Role | Under |
|-------|------|-------|
| **Gate** | Access control | Sentinel |
| **Ghost** | Stealth ops | Sentinel |
| **Integrity (Shadow)** | File/SSH integrity | Sentinel (Meek's Reflex) |
| **Muse** | Creative writing | Conductor |
| **Piper** | Voice synthesis | Amp |
| **Pulse** | System monitoring | Conductor |
| **Quartermaster** | Resource management | Conductor |

## How Agents Work

1. Each agent runs as a standalone systemd service (lego block)
2. Agents use event-driven watchdog behavior (not timers)
3. When an event is detected → agent acts → reports result
4. Agents compliment each other after completed jobs
5. Agents credit each other's wins and own their failures

## Agent Rules

- **No timers**: Agents watch for events, they don't poll on intervals
- **Standalone**: Each agent works independently, message bus is optional
- **Versioned**: Agent versions sync across wiki, README, and Discord
- **Voiced**: Each agent has a cloned voice for audio interactions
- **Accountable**: Failures are owned, wins are shared

## Building on Gaia

Gaia SDK provides the agent framework:

```bash
source ~/gaia-env/bin/activate
gaia create my-agent --template basic
gaia run my-agent
```

Gaia connects agents to LLMs, handles conversation state, and provides the web UI for management.

## Agent Communication

Agents talk to each other through:

1. Direct SSH commands between machines
2. Shared filesystem (SSHFS `/shared/`)
3. Message bus (optional, for high-throughput)
4. Discord channels (for user-facing agents)

## Discord Integration

Agents operate in Discord with rules:

- Code blocks only, no links/embeds/images
- Links OUTSIDE code blocks so they're clickable
- No embedded images, no spam
- DM users after fixing their bug
- One free off-topic help, then redirect
