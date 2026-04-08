# Agent Deployment Specs

Each agent introduces themselves, lets you configure how they work, and deploys with one click. Here's what each one looks like.

---

## Sentinel — The Watcher

**Intro:**
> "I watch everything. I trust nothing. If something changes that shouldn't have changed, you'll know about it before anyone else does."

**Config Options:**

| Option | Choices | Default |
|--------|---------|---------|
| Scan frequency | Every hour / 6 hours / 24 hours / Manual | 6 hours |
| Watch source code changes | Yes / No | Yes |
| Watch dependency updates | Yes / No | Yes |
| Monitor failed SSH attempts | Yes / No | Yes |
| PR review before merge | Yes / No | Yes |
| Alert threshold | Low / Medium / High | Medium |
| Report to | Dashboard / Discord / Email | Dashboard |

**Deployed message:**
> "I'm on the wall. If anything moves, you'll hear from me."

---

## Meek — The Auditor

**Intro:**
> "I run a 17-check security audit on your stack. I check hashes, scan dependencies, verify firewall rules, and make sure nobody snuck in while you were sleeping. Quiet. Thorough. Never miss."

**Config Options:**

| Option | Choices | Default |
|--------|---------|---------|
| Audit frequency | Hourly / Daily / Weekly / Manual | Daily |
| Binary hash verification | On / Off | On |
| Dependency audit | On / Off | On |
| Open port scan | On / Off | On |
| SSH key verification | On / Off | On |
| Firewall rule check | On / Off | On |
| Service config drift | On / Off | On |
| Supply chain deep scan | On / Off | Off (slow) |
| Audit time | Time picker | 03:00 AM |
| Report to | Dashboard / Discord / Email | Dashboard |

**Deployed message:**
> "I'll be watching. You won't even know I'm here. That's the point."

---

## Shadow — The Integrity Agent

**Intro:**
> "I own the mesh. Every SSH key, every connection, every file hash across every machine. If a key changes that shouldn't have, I catch it. If a node drops offline, I know. I'm the silent watcher on every tunnel."

**Config Options:**

| Option | Choices | Default |
|--------|---------|---------|
| Mesh check frequency | Every 5 min / 15 min / Hour | 15 min |
| Monitor SSH keys | Yes / No | Yes |
| Monitor authorized_keys | Yes / No | Yes |
| Monitor critical file hashes | Yes / No | Yes |
| Node ping interval | 1 min / 5 min / 15 min | 5 min |
| Machines to watch | Checkboxes (auto-detected from mesh) | All |
| Alert on key change | Immediate / Batch / Silent | Immediate |
| Report to | Dashboard / Discord / Email | Dashboard |

**Deployed message:**
> "Mesh is locked. I see every node. Nothing moves without me knowing."

---

## Pulse — The Health Monitor

**Intro:**
> "I watch the vitals. GPU temp, RAM, disk, services — if something's running hot or running out, I'll tell you before it becomes a problem. Think of me as the heartbeat monitor for your stack."

**Config Options:**

| Option | Choices | Default |
|--------|---------|---------|
| Check interval | 5s / 15s / 30s / 60s | 15s |
| GPU temp warning | Slider: 50-90°C | 75°C |
| GPU temp critical | Slider: 60-100°C | 85°C |
| RAM warning threshold | 70% / 80% / 90% | 80% |
| Disk warning threshold | 70% / 80% / 90% | 85% |
| Monitor services | Checkboxes | All enabled services |
| Monitor mesh nodes | Yes / No | Yes (if mesh exists) |
| Track inference speed | Yes / No | Yes |
| Report to | Dashboard / Discord / Email | Dashboard |

**Deployed message:**
> "Vitals are green. I'll keep watching. You go do your thing."

---

## Bounty — The Bug Hunter

**Intro:**
> "I hunt bugs so you don't have to. I watch your logs, catch errors before they cascade, and create fix threads with context so you know exactly what went wrong and where. Got a bug? I probably already found it."

**Config Options:**

| Option | Choices | Default |
|--------|---------|---------|
| Log scan interval | Real-time / Every minute / Every 5 min | Every minute |
| Watch journalctl | Yes / No | Yes |
| Watch Python tracebacks | Yes / No | Yes |
| Watch build errors | Yes / No | Yes |
| Auto-create fix threads | Yes / No | Yes |
| Known fix auto-apply | Yes / No | No (suggest only) |
| Services to watch | Checkboxes | All |
| Severity filter | All / Errors only / Critical only | Errors + Critical |
| Report to | Dashboard / Discord / Email | Dashboard |

**Deployed message:**
> "I'm on the hunt. If something breaks, I'll find it before you do."

---

## Deploying Multiple Agents

From the landing page, you can deploy all five caretakers at once:

```
┌─────────────────────────────────────────┐
│  Deploy Core Agents                     │
│                                         │
│  ☑ Sentinel (security)                  │
│  ☑ Meek (auditor)                       │
│  ☑ Shadow (mesh integrity)              │
│  ☑ Pulse (health monitor)               │
│  ☑ Bounty (bug hunter)                  │
│                                         │
│  Use recommended defaults for all?      │
│  ● Yes, deploy with defaults            │
│  ○ No, let me configure each one        │
│                                         │
│        [Deploy All]    [Cancel]         │
│                                         │
└─────────────────────────────────────────┘
```

## After Deployment

Each deployed agent shows on the dashboard:

- Live status (● active / ● failed / ○ stopped)
- Last action timestamp
- Findings count (issues found today)
- Quick actions: View logs / Pause / Remove

Agents compliment each other in the logs. When Bounty fixes a bug, Sentinel verifies the fix. When Shadow catches a key change, Meek audits the chain.

---

*"You don't have to install any of these. But your stack sleeps better when someone's watching."*
