# SSH Mesh

Connect multiple machines into a fully bidirectional SSH mesh. Every machine can reach every other machine. No VPNs, no tunnels, just SSH keys.

## Concept

```
    ┌──────┐     ┌──────┐
    │Strix │ ←→  │Sliger│
    │ .10  │     │ .20  │
    └──┬───┘     └──┬───┘
       │     ↕      │
    ┌──┴───┐     ┌──┴───┐
    │Ryzen │ ←→  │  Pi  │
    │ .25  │     │ .40  │
    └──┬───┘     └──────┘
       │
    ┌──┴────┐
    │  Mini │
    │  .30  │
    └───────┘
    ALL ←→ ALL (full mesh)
```

## Setup

### 1. Generate Key on Each Machine

```bash
ssh-keygen -t ed25519 -C "bcloud@machinename"
```

### 2. Distribute Public Keys

Every machine's public key goes into every other machine's `~/.ssh/authorized_keys`:

```bash
# From the new machine, copy key to all existing nodes
ssh-copy-id bcloud@10.0.0.10   # strix-halo
ssh-copy-id bcloud@10.0.0.20   # sliger
ssh-copy-id bcloud@10.0.0.25   # ryzen
ssh-copy-id bcloud@10.0.0.40   # pi
```

Then from each existing node, copy THEIR key to the new machine.

### 3. SSH Config

Create `~/.ssh/config` on every machine:

```
Host strix-halo
    HostName 10.0.0.10
    User bcloud
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

Host sliger
    HostName 10.0.0.20
    User bcloud
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

Host ryzen
    HostName 10.0.0.25
    User bcloud
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

Host pi
    HostName 10.0.0.40
    User bcloud
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

Now `ssh strix-halo` just works.

### 4. Verify

```bash
# Test from each machine
ssh strix-halo "echo ok"
ssh sliger "echo ok"
ssh ryzen "echo ok"
ssh pi "echo ok"
```

## Mesh Bootstrap Script

For fresh installs, use the bootstrap script:

```bash
scp -r mesh-bootstrap/ bcloud@<new-ip>:~/
ssh bcloud@<new-ip> "sudo bash ~/mesh-bootstrap/bootstrap.sh"
```

This auto-creates the user, installs SSH keys, writes mesh config, and enables sshd.

## Windows Machines

Windows OpenSSH uses a different authorized_keys file for admin users:

```
C:\ProgramData\ssh\administrators_authorized_keys
```

NOT `~/.ssh/authorized_keys`. Always check which file Windows is reading.

## SSHFS Shared Storage

Mount remote directories as local folders:

```bash
sshfs bcloud@strix-halo:/shared /mnt/strix-shared
```

For permanent mounts, add to `/etc/fstab`:

```
bcloud@strix-halo:/shared /mnt/strix-shared fuse.sshfs defaults,_netdev,reconnect 0 0
```

## Security

- Key-only auth on all machines
- No password auth, no root login
- Rotate keys if a machine is compromised
- Shadow agent monitors mesh integrity
