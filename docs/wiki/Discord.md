# Discord Server

> Keep it simple. People are here for help, not a maze.

## Channel Structure

### WELCOME
| Channel | Purpose |
|---------|---------|
| `#welcome` | Auto-greet new members |
| `#rules` | Server rules, code of conduct |
| `#announcements` | Releases, updates, important news |

### BENCHMARKS
| Channel | Purpose |
|---------|---------|
| `#echo` | Echo agent's public feed |
| `#digest` | Daily digest — what happened, what changed |
| `#security` | Security advisories, audits, incidents |
| `#changelog` | Version history, what's new in each release |

### SUPPORT
| Channel | Purpose |
|---------|---------|
| `#bug-reports` | Something broke? Report it here |
| `#installation` | Help getting core installed |
| `#troubleshooting` | Post-install problems |
| `#self-hosting` | Running your own stack, custom configs |
| `#hardware` | AMD hardware questions, specs, compatibility |

### GENERAL
| Channel | Purpose |
|---------|---------|
| `#water-cooler` | Off-topic chat, hang out |
| `#show-and-tell` | Show what you built on your stack |
| `#ideas` | Feature requests, lego block ideas |
| `#pet-love` | Pictures of your pets. That's it. That's the channel. |

### AI
| Channel | Purpose |
|---------|---------|
| `#models` | Model recommendations, comparisons, GGUF talk |
| `#local-llm` | Running LLMs locally, llama.cpp, configs |
| `#voice-tts` | Whisper, Kokoro, voice cloning, audio |
| `#imaging` | ComfyUI, stable diffusion, image/video gen |

## Agent Rules (Hard Coded)

These are non-negotiable. Every agent follows these rules in every channel.

### 1. Code Blocks Only
All agent responses are wrapped in code blocks. No exceptions. No markdown formatting outside of code blocks. No rich text.

```
Like this. Always like this.
Every response. Every query. Every answer.
```

### 2. No Images, No Embeds
Agents never post images. Never post embeds. Never blast pictures. Text only in code blocks.

### 3. No Sales Pitch
Users are already here. They already have the stack or they're getting it. Agents do NOT:
- Push "install halo-ai-core"
- Link to the repo unprompted
- Promote features nobody asked about
- Act like a marketing bot

Answer the question. Help with the problem. That's it.

### 4. Links Outside Code Blocks
When an agent needs to share a link, it goes OUTSIDE the code block so it's clickable:

```
Here's how to fix the ROCm path issue:
export PATH=$PATH:/opt/rocm/bin
```
Full guide: https://github.com/stampby/halo-ai-core/docs/wiki/ROCm-Tuning.md

### 5. One Free Off-Topic Help
If someone asks about something unrelated to halo-ai-core, the agent helps once. After that: "That's outside my scope. Try #water-cooler or the relevant community."

### 6. DM After Bug Fix
When an agent helps fix a bug, it DMs the user: "Your issue in #bug-reports is resolved. Let us know if it comes back." Make them feel heard.

### 7. Auto-Thread for Support
Bug reports and support issues auto-create threads. Keeps the main channels clean.

## Digest Format

Daily digest in `#digest` uses code blocks with timestamps:

```
📅 2026-04-08 Daily Digest

06:12 — ROCm 7.2.1 kernel cache compiled (first-run complete)
09:30 — Qwen3-8B benchmark: 88.2 tok/s decode
14:15 — Wiki updated: 28 pages
18:00 — v0.9.0 install script tested clean

Previous digest → thread
30-day retention
```

## Join

https://discord.gg/dSyV646eBs
