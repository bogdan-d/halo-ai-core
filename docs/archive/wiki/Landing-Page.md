# Landing Page — The Dashboard

> *"Welcome to the real world." — Morpheus*

The landing page is where everything lives after core is installed. It's the control center — hardware stats, service management, agent deployment, and lego block installation. All from one page.

## What You See

```
┌─────────────────────────────────────────────────────────────┐
│  ◉ halo-ai core                          strixhalo  12:34  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ GPU          │  │ RAM          │  │ DISK         │      │
│  │ gfx1151      │  │ 41/128 GB    │  │ 234/1900 GB  │      │
│  │ 45°C  23%   │  │ ████░░░░░░░  │  │ ██░░░░░░░░░  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                             │
│  ── CORE SERVICES ──────────────────────────────────────    │
│                                                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │ llama.cpp│ │ Lemonade │ │   Gaia   │ │  Caddy   │      │
│  │ ● active │ │ ● active │ │ ● active │ │ ● active │      │
│  │ :8080    │ │ :13305   │ │          │ │ :80      │      │
│  │ [manage] │ │ [manage] │ │ [manage] │ │ [manage] │      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
│                                                             │
│  ── RECOMMENDED AGENTS ─────────────────────────────────    │
│  "these watch your stack when you're not around"            │
│                                                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │ Sentinel │ │   Meek   │ │  Shadow  │ │  Pulse   │      │
│  │ security │ │  auditor │ │ integrity│ │  health  │      │
│  │ ○ ready  │ │ ○ ready  │ │ ○ ready  │ │ ○ ready  │      │
│  │ [deploy] │ │ [deploy] │ │ [deploy] │ │ [deploy] │      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
│                                                             │
│  ┌──────────┐                                               │
│  │  Bounty  │                                               │
│  │bug hunter│                                               │
│  │ ○ ready  │                                               │
│  │ [deploy] │                                               │
│  └──────────┘                                               │
│                                                             │
│  ── LEGO BLOCKS ────────────────────────────────────────    │
│  "snap on what you need"                                    │
│                                                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │ SSH Mesh │ │Open WebUI│ │ ComfyUI  │ │  Voice   │      │
│  │ network  │ │   chat   │ │  images  │ │ pipeline │      │
│  │ [install]│ │ [install]│ │ [install]│ │ [install]│      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
│                                                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │
│  │  Games   │ │GlusterFS │ │ SearXNG  │ │ Discord  │      │
│  │Minecraft │ │ storage  │ │  search  │ │   bots   │      │
│  │ [install]│ │ [install]│ │ [install]│ │ [install]│      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Hardware Panel

Live stats at the top. Always visible.

| Metric | Source | Update |
|--------|--------|--------|
| GPU model + temp + utilization | `rocm-smi` | 5s |
| RAM used / total | `/proc/meminfo` | 5s |
| Disk used / total | `df` | 30s |
| CPU model + load | `/proc/cpuinfo` + `/proc/loadavg` | 5s |
| NPU status | `rocminfo` | 30s |
| Uptime | `/proc/uptime` | 60s |
| Network (mesh nodes online) | SSH ping | 60s |

## Core Services Panel

Each service card shows:

- **Name** and port
- **Status** indicator: ● active (green), ● failed (red), ○ stopped (grey)
- **[manage]** button → opens service detail:
  - Start / Stop / Restart
  - View logs (last 50 lines, live tail)
  - Edit configuration
  - Current model loaded (for llama.cpp)

## Agent Deployment Flow

When you click **[deploy]** on an agent:

### Step 1 — Introduction

```
┌─────────────────────────────────────────┐
│                                         │
│  👋 Hey. I'm Meek.                      │
│                                         │
│  I run a 17-check security audit on     │
│  your stack every day. I check binary   │
│  hashes, scan dependencies, verify      │
│  firewall rules, and make sure nobody   │
│  snuck in while you were sleeping.      │
│                                         │
│  Want me on the job?                    │
│                                         │
│        [Configure]    [Not now]         │
│                                         │
└─────────────────────────────────────────┘
```

### Step 2 — Configuration

```
┌─────────────────────────────────────────┐
│  Meek — Configuration                  │
│                                         │
│  How often should I audit?              │
│  ○ Every hour                           │
│  ● Every 24 hours (recommended)         │
│  ○ Weekly                               │
│  ○ Manual only                          │
│                                         │
│  What should I check?                   │
│  ☑ Binary hash verification             │
│  ☑ Dependency audit                     │
│  ☑ Open port scan                       │
│  ☑ SSH key verification                 │
│  ☑ Firewall rules                       │
│  ☑ Service config drift                 │
│  ☐ Supply chain deep scan (slow)        │
│                                         │
│  Where should I report?                 │
│  ☑ Dashboard (always)                   │
│  ☐ Discord channel                      │
│  ☐ Email                                │
│                                         │
│        [Deploy Meek]    [Back]          │
│                                         │
└─────────────────────────────────────────┘
```

### Step 3 — Deploy

Click **[Deploy Meek]** and the system:

1. Downloads the agent package
2. Creates `~/agents/meek/`
3. Writes the config based on your choices
4. Creates `meek.service` systemd unit
5. Adds Caddy route if needed
6. Starts the service
7. Meek says hello:

```
┌─────────────────────────────────────────┐
│                                         │
│  ✓ Meek is live.                        │
│                                         │
│  "I'll be watching. You won't even      │
│   know I'm here. That's the point."    │
│                                         │
│  First audit scheduled: 03:00 AM       │
│  Reporting to: Dashboard               │
│  Status: ● active                       │
│                                         │
│        [View Meek]    [Done]            │
│                                         │
└─────────────────────────────────────────┘
```

## Lego Block Install Flow

Similar to agents but simpler — less personality, more utility:

1. Click **[install]** on a block
2. See what it does and what it needs
3. Configure options (ports, paths)
4. Click **[install]** → systemd service created, Caddy route added
5. Block appears in the core services panel

## Tech Stack for the Landing Page

| Component | Purpose |
|-----------|---------|
| **HTMX** | Dynamic updates without a JS framework |
| **Alpine.js** | Lightweight interactivity |
| **SSE** | Server-sent events for live stats |
| **FastAPI** | Python backend, talks to systemd |
| **Caddy** | Serves the page on :80 |

No React. No npm. No node_modules. Just HTML that works.

### Why HTMX + Alpine

- **HTMX**: Click a button → server does the work → HTML fragment comes back → page updates. No JSON APIs, no client-side state management.
- **Alpine**: Small interactions (dropdowns, toggles, modals) without pulling in a framework.
- **SSE**: Hardware stats push to the browser every 5 seconds. No polling.

## API Endpoints (FastAPI)

```
GET  /api/status              # All service statuses
GET  /api/hardware             # GPU, RAM, disk, CPU stats
GET  /api/services/{name}      # Detail for one service
POST /api/services/{name}/start
POST /api/services/{name}/stop
POST /api/services/{name}/restart
GET  /api/services/{name}/logs # Last 50 lines
GET  /api/agents               # Available agents
POST /api/agents/{name}/deploy # Deploy with config
POST /api/agents/{name}/remove
GET  /api/blocks               # Available lego blocks
POST /api/blocks/{name}/install
POST /api/blocks/{name}/remove
GET  /api/stream/hardware      # SSE stream for live stats
```

## File Structure

```
landing/
├── app.py              # FastAPI backend
├── templates/
│   ├── index.html      # Main dashboard
│   ├── partials/
│   │   ├── hardware.html    # Hardware stats fragment
│   │   ├── services.html    # Service cards fragment
│   │   ├── agents.html      # Agent cards fragment
│   │   └── blocks.html      # Lego block cards fragment
│   └── modals/
│       ├── service-detail.html
│       ├── agent-intro.html
│       ├── agent-config.html
│       └── agent-deployed.html
├── static/
│   ├── style.css
│   └── alpine.min.js
└── requirements.txt    # fastapi, uvicorn, psutil
```

## Access

The landing page runs on Caddy's port 80. From any machine in the mesh:

```bash
ssh -L 8080:localhost:80 strix-halo
# Open browser → http://localhost:8080
```

Or access directly if on the same LAN (Caddy listens on :80).

---

*The landing page is the face of core. Everything starts here.*
