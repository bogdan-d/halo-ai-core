# Security Hardening

> *"You shall not pass." — Gandalf*

## Why This Matters

LLMs have no concept of authorization. They see everything. Every file, every config, every secret on the machine they run on. If someone gets access to your box, they get access to everything — your models, your data, your voice samples, your SSH keys.

That's why Halo AI Core locks everything down by default. Not because we're paranoid. Because the alternative is stupid.

## What's Locked Down

### Layer 1 — Firewall (nftables)

```
Input policy: DROP (everything blocked by default)
Only port 22 (SSH) is allowed inbound
Forward policy: DROP
Output policy: ACCEPT
```

If it's not SSH, it doesn't get in. Period. All services run on `127.0.0.1` — they're only reachable from the machine itself or through SSH.

**Verify:**
```bash
sudo nft list ruleset | grep policy
# Should show: policy drop (input), policy drop (forward), policy accept (output)
```

### Layer 2 — SSH Hardening

```
PasswordAuthentication no    # No passwords, ever
PubkeyAuthentication yes     # Keys only
PermitRootLogin no           # Root can't SSH in
```

You need an ed25519 key to get in. No key, no access. No exceptions.

**Verify:**
```bash
cat /etc/ssh/sshd_config.d/mesh.conf
```

### Layer 3 — Fail2ban

3 failed SSH attempts = 1 hour ban. Automated brute force protection.

```
maxretry = 3
findtime = 10m
bantime = 1h
```

**Verify:**
```bash
sudo fail2ban-client status sshd
```

### Layer 4 — Service Isolation

Every service binds to `127.0.0.1`:

| Service | Binds To | Port |
|---------|----------|------|
| llama-server | 127.0.0.1 | 8080 |
| Lemonade UI | 127.0.0.1 | 13305 |
| Gaia UI | 127.0.0.1 | 4200 | Optional — only if Gaia web UI enabled |
| Caddy | 127.0.0.1 | 80 |

Nothing listens on `0.0.0.0` except SSH. Caddy proxies internally.

### Layer 5 — Automatic Updates

Daily at 4 AM, the system runs `pacman -Syu --noconfirm`. Security patches are applied automatically. Logged to `/var/log/auto-update.log`.

**Verify:**
```bash
systemctl list-timers auto-update.timer
cat /var/log/auto-update.log
```

### Layer 6 — Integrity Checking

Daily at 5 AM, the integrity checker runs. It monitors:

- SSH config files
- Caddy config
- Firewall rules
- All systemd service files
- llama.cpp binaries
- ROCm environment
- Open ports (flags anything on 0.0.0.0 that isn't SSH)
- fail2ban status
- nftables status

If any file hash changes unexpectedly, it logs an alert.

**Verify:**
```bash
sudo /usr/local/bin/halo-integrity-check
cat /var/log/halo-integrity.log
```

**Re-initialize after intentional changes:**
```bash
sudo /usr/local/bin/halo-integrity-check --init
```

### Layer 7 — Log Rotation

- journald: 500MB max, 1 month retention, compressed
- Custom logs: weekly rotation, 4 weeks retained

Logs don't fill your disk. Old data gets compressed and eventually removed.

## Accessing Services Safely

Since everything is on localhost, you access services through SSH:

```bash
# Option 1: SSH tunnel (recommended)
ssh -L 8080:localhost:13305 strix-halo
# Open browser: http://localhost:8080

# Option 2: Run commands remotely
ssh strix-halo "curl -s localhost:13305/health"

# Option 3: SSH and work locally on the box
ssh strix-halo
curl localhost:13305
```

**Never expose ports directly.** The firewall blocks them for a reason.

## Why No Web Panel Login?

Other platforms put a login page on port 443 and call it secure. We don't. Here's why:

- Login pages are attack surfaces (credential stuffing, XSS, session hijacking)
- SSH keys are stronger than any password
- One less thing to patch, one less thing to break
- If you have the SSH key, you're already authenticated

## Daily Security Schedule

| Time | What Happens |
|------|-------------|
| 4:00 AM | Auto-update (`pacman -Syu`) |
| 5:00 AM | Integrity check (file hashes, ports, services) |
| Continuous | Fail2ban monitoring SSH attempts |
| Continuous | nftables blocking non-SSH inbound |

## Testing Your Security

From another machine on the network:

```bash
# SSH should work
ssh strix-halo "echo ok"

# Everything else should fail
curl --connect-timeout 3 http://10.0.0.10:80    # BLOCKED
curl --connect-timeout 3 http://10.0.0.10:13305  # BLOCKED
curl --connect-timeout 3 http://10.0.0.10:4200   # BLOCKED
```

If any of those `curl` commands succeed, your firewall is misconfigured.

## btrfs Snapshots

Before any change, snapshot. After any incident, rollback.

```bash
# Current snapshots
sudo btrfs subvolume list / | grep snapshot

# Rollback to last known good
# (from live USB)
mount /dev/nvme0n1p2 /mnt -o subvol=/
mv /mnt/@ /mnt/@.broken
btrfs subvolume snapshot /mnt/.snapshots/hardened-2026-04-08 /mnt/@
reboot
```

## Past Incidents

We document everything publicly. Glass walls.

- **2026-03-31**: axios supply chain attack — tokens rotated, stack frozen, documented in [GitHub Advisory](https://github.com/stampby/halo-ai/security/advisories/GHSA-3gp9-qwch-x5wv)

---

*Your stack is locked down. SSH key or nothing. "You shall not pass."*
