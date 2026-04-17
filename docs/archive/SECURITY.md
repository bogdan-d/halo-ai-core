# Security — SSH Keys Only

> "You think that's air you're breathing now?" — Morpheus

Halo AI Core runs **SSH-only**. No open ports. No web panels exposed to the network. No passwords. You SSH in or you don't get in.

## Why SSH Only

- No attack surface — nothing listens except port 22
- Key-based auth — no brute force possible
- All services bind to `localhost` — Caddy proxies internally only
- From outside the LAN, you need the key AND the IP

## Quick Setup (New Machine)

### 1. Generate a Key

```bash
# On YOUR machine (not the server)
ssh-keygen -t ed25519 -C "yourname@yourmachine"
```

This creates:
- `~/.ssh/id_ed25519` — your **private** key (NEVER share this)
- `~/.ssh/id_ed25519.pub` — your **public** key (this goes on the server)

### 2. Copy Key to the Server

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub bcloud@10.0.0.10
```

Or manually:

```bash
# On the server
mkdir -p ~/.ssh
echo "YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### 3. Test It

```bash
ssh bcloud@10.0.0.10
```

No password prompt = you're in.

### 4. Lock It Down

The install script already does this, but verify:

```bash
# /etc/ssh/sshd_config.d/mesh.conf
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
```

## SSH Config (Mesh)

Instead of remembering IPs, create `~/.ssh/config`:

```
Host strix-halo
    HostName 10.0.0.10
    User bcloud
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

Now just type `ssh strix-halo`.

## Multi-Machine Mesh

Every machine in the mesh needs:
1. Its own ed25519 key
2. Every other machine's public key in `authorized_keys`
3. SSH config entries for every other machine

The mesh bootstrap script at `mesh-bootstrap/` handles all of this automatically.

## Rules

- **NEVER** expose services to the network directly
- **NEVER** enable password auth
- **NEVER** allow root login
- **ALWAYS** use ed25519 keys (not RSA)
- **ALWAYS** keep private keys on the machine that generated them
- Rotate keys if a machine is compromised

## Windows (Minisforum)

Windows OpenSSH has a quirk: admin users' keys go in a different file:

```
C:\ProgramData\ssh\administrators_authorized_keys
```

NOT `~/.ssh/authorized_keys`. The install script handles this, but if you're adding keys manually, put them in the right place.
