# Core Agents — Stack Caretakers

> *"You don't have to install these. But they'll watch your back when you're not around."*

These agents aren't part of Halo AI Core. Core is the foundation — it runs without agents. But once your stack is up, these five will keep it healthy, secure, and running while you sleep.

They're a recommendation, not a requirement.

## The Caretakers

| Agent | What It Does | Why You Want It |
|-------|-------------|-----------------|
| **Sentinel** | Security watcher | Scans for vulnerabilities, monitors code integrity, reviews PRs |
| **Meek** | Stack auditor | 17-check daily audit, supply chain scanning, dependency verification |
| **Shadow** | Mesh integrity | Monitors SSH keys, file hashes, connection health across all machines |
| **Pulse** | System monitor | GPU temps, RAM usage, disk space, service health — alerts when something's off |
| **Bounty** | Bug hunter | Catches errors in logs, auto-creates threads for issues, tracks fixes |

## What They Do Together

```
┌─────────────────────────────────────────┐
│           Your Stack (sleeping)          │
├─────────┬─────────┬─────────┬──────────┤
│Sentinel │  Meek   │ Shadow  │  Pulse   │
│security │ audits  │  mesh   │ health   │
├─────────┴─────────┴─────────┴──────────┤
│              Bounty (bugs)              │
└─────────────────────────────────────────┘
          ↓ something wrong? ↓
      you get told about it.
```

## Sentinel — The Watcher

Sentinel trusts nothing. It monitors:

- Source code integrity (did a file change unexpectedly?)
- Dependency versions (did something update without approval?)
- Failed SSH attempts
- Unusual process activity
- PR reviews before merge

*"I am the watcher on the wall."*

## Meek — The Auditor

Meek runs a 17-point security check daily:

- SHA256 verification of all binaries
- GPG signature checks
- Service configuration drift detection
- Open port scanning (there should be only one: 22)
- Supply chain dependency audit
- SSL/TLS certificate expiry
- Firewall rule verification

Quiet, thorough, never misses.

## Shadow — The Integrity Agent

Shadow owns the SSH mesh. It watches:

- SSH key fingerprints across all machines (did a key change?)
- File hashes on critical configs
- Connection health between mesh nodes
- Authorized_keys files (did someone add an unknown key?)

If a key changes unexpectedly, Shadow flags it immediately.

## Pulse — The Health Monitor

Pulse watches the vitals:

- GPU temperature and utilization
- RAM and swap usage
- Disk space across all drives
- systemd service status (is anything down?)
- Network connectivity between mesh nodes
- Model inference speed (did performance degrade?)

When something crosses a threshold, Pulse alerts you.

## Bounty — The Bug Hunter

Bounty watches logs for errors:

- journalctl for service failures
- Build errors during updates
- Python tracebacks in agent logs
- User-reported issues (via Discord or web)

When it finds something, it auto-creates a thread with the error, the context, and a suggested fix if one is known.

## Installing Core Agents

Core agents are lego blocks. They snap on after core is running:

```bash
# Coming soon — each agent will be a separate install
./install-agents.sh --caretakers    # Install all 5 caretakers
./install-agents.sh --sentinel      # Or pick individual ones
```

Each agent runs as its own systemd service. Each can be installed or removed independently.

## Do I Need All Five?

No. Start with what matters to you:

- **Security-focused?** → Sentinel + Meek
- **Multi-machine?** → Shadow + Pulse
- **Just want peace of mind?** → Pulse alone catches most problems
- **Want the full crew?** → All five, they complement each other

They compliment each other's work too. When Bounty fixes a bug, Sentinel verifies the fix. When Shadow detects a key change, Meek audits the whole chain. They're a team.

---

*These agents are optional. Core runs without them. But your stack sleeps better when someone's watching.*
