# Lemonade Nexus — Zero-Trust Mesh VPN

*"Now I have a machine gun. Ho ho ho." — John McClane, Die Hard*

SSH Mixer is deprecated. Nexus replaces it. Here's why and how.

---

## Why Not SSH Mesh?

SSH mesh works. We used it. 5 machines, full key exchange, ~/.ssh/config on every box. It got the job done.

But it doesn't scale. Every new machine means touching every existing machine. Key rotation is manual. There's no encryption beyond SSH itself. No governance. No health monitoring. No automatic tunnel establishment.

Nexus solves all of that.

## What Is Nexus?

Lemonade Nexus is a self-hosted WireGuard mesh VPN with cryptographic governance. It's part of the [Lemonade SDK](https://github.com/lemonade-sdk/lemonade) ecosystem.

**What it gives you:**

| Feature | Description |
|---------|-------------|
| **Zero-trust** | TEE hardware attestation (SGX/TDX/SEV-SNP) for Tier 1 authority |
| **Ed25519 identity** | Every server and client gets a unique keypair |
| **Root key rotation** | Automatic weekly rotation with chain-of-trust |
| **Shamir's Secret Sharing** | Root key distributed across Tier 1 peers, 75% quorum to reconstruct |
| **Democratic governance** | Protocol changes require Tier 1 majority vote |
| **Peer health gating** | Only servers with ≥90% uptime qualify for Tier 1 |
| **WireGuard mesh** | Automatic tunnel establishment with STUN hole-punching |
| **Federated relays** | Community relays see only ciphertext |
| **IPAM** | Automatic /10 tunnel IP allocation |
| **ACME certificates** | Automatic TLS via Let's Encrypt or ZeroSSL |
| **Distributed DNS** | Every Tier 1 peer serves the same DNS zone |
| **WebAuthn passkeys** | Passwordless authentication for management |
| **No database** | All state stored as signed JSON files on disk |

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                   Lemonade-Nexus Server                   │
├───────────────────┬──────────────────────────────────────┤
│ Public API :9100  │  Private API :9101 (VPN-only)        │
├───────────────────┴──────────────────────────────────────┤
│  Auth · ACL · IPAM · ACME · Relay · DDNS · DNS          │
├──────────────────────────────────────────────────────────┤
│  UDP Gossip :9102  ·  WireGuard :51940  ·  STUN :3478   │
├──────────────────────────────────────────────────────────┤
│  Ed25519 Identity  ·  Shamir SSS  ·  Permission Tree    │
└──────────────────────────────────────────────────────────┘
```

## Build From Source

Nexus is built from source. Not from pacman. Not from pip. From source.

```bash
# clone
git clone https://github.com/lemonade-sdk/lemonade-nexus.git ~/lemonade-nexus

# build
cd ~/lemonade-nexus
mkdir -p build && cd build
cmake ..
make -j$(nproc)

# install binary
sudo install -m755 projects/LemonadeNexus/lemonade-nexus /usr/local/bin/lemonade-nexus
```

Build time: ~2 minutes on 32 cores.

## Systemd Service

```ini
[Unit]
Description=Lemonade Nexus — Cryptographic WireGuard Mesh VPN
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/lemonade-nexus \
    --data-root /home/bcloud/.local/share/lemonade-nexus/data \
    --log-level info
Restart=on-failure
RestartSec=10
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable --now lemonade-nexus
```

## Verify

```bash
# check it's running
systemctl status lemonade-nexus

# check ports
ss -tlnp | grep -E '9100|9101|9102'

# check WireGuard tunnel
ip a | grep 10.64
```

You should see:
- `:9100` — public API (bootstrap, enrollment)
- `:9101` — private API (VPN-only, sensitive operations)
- `10.64.0.1` — your WireGuard tunnel IP

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 9100 | TCP | Public HTTP API |
| 9101 | TCP | Private VPN-only API |
| 9102 | UDP | Gossip protocol |
| 51940 | UDP | WireGuard + hole-punch |
| 3478 | UDP | STUN |
| 9103 | UDP | Relay |

## SSH Mesh Still Works

Nexus doesn't remove SSH. Your SSH keys, your `~/.ssh/config`, your mesh — all still there. Nexus adds encrypted WireGuard tunnels on top. SSH rides inside the tunnel now.

The [SSH Mesh guide](SSH-Mesh.md) is still valid for the basic setup. Nexus is the upgrade path.

## What's Next

- Multi-machine enrollment (Ryzen, Sliger, Pi)
- Peer health monitoring dashboard
- Automatic failover routing
- Integration with the [Package Manager](Components.md)

---

> *"roads? where we're going, we don't need roads."*

**[← Back to Wiki Home](Home.md)** · **[Architecture →](Architecture.md)** · **[SSH Mesh →](SSH-Mesh.md)**
