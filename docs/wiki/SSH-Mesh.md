# SSH Mesh — Multi-Machine Networking

*"You mustn't be afraid to dream a little bigger, darling." — Eames, Inception*

~~We thought about using Kubernetes. Then we remembered we're not insane.~~

SSH. That's it. Every machine talks to every other machine over SSH keys. No VPNs between machines. No cloud relay. No container orchestration. Just keys and config files. It works everywhere, it's bulletproof, and it takes 10 minutes to set up.

---

## The Network

5 machines, full mesh. Every machine can reach every other machine by hostname.

```
                    ┌─────────────────────────┐
                    │      10.0.0.0/24        │
                    │    Home LAN (switch)     │
                    └───┬────┬────┬────┬────┬─┘
                        │    │    │    │    │
                   .10  │   .20  │   .25  │   .30  │   .40
              ┌─────────┴┐ ┌┴────────┐ ┌┴────────┐ ┌┴───────┐ ┌┴──────┐
              │  STRIX   │ │ SLIGER  │ │  RYZEN  │ │  MINI  │ │   PI  │
              │  HALO    │ │         │ │         │ │ FORUM  │ │   5   │
              ├──────────┤ ├─────────┤ ├─────────┤ ├────────┤ ├───────┤
              │ 395 APU  │ │ 8700K   │ │ 5900X   │ │ Win11  │ │ ARM64 │
              │ 128GB    │ │ 1080 Ti │ │ 64GB    │ │ 32GB   │ │ 8GB   │
              │ Arch     │ │ Arch    │ │ Arch    │ │ Win11  │ │ Arch  │
              │ PRIMARY  │ │ GAME    │ │ AUDIO   │ │ MISC   │ │ IOT   │
              └──────────┘ └─────────┘ └─────────┘ └────────┘ └───────┘
                   ↕            ↕            ↕           ↕         ↕
              ALL  ←→  ALL  ←→  ALL  ←→  ALL  ←→  ALL (full mesh)
```

| Machine | IP | Role | OS | Hardware |
|---------|------|------|------|----------|
| **strix-halo** | 10.0.0.10 | Primary — LLM, agents, dashboard | Arch Linux | Ryzen AI MAX+ 395, 128GB |
| **sliger** | 10.0.0.20 | Game servers, Minecraft, GPU workloads | Arch Linux | i7-8700K, GTX 1080 Ti |
| **ryzen** | 10.0.0.25 | Audio recording, voice training, dev | Arch Linux | Ryzen 9 5900X, 64GB |
| **minisforum** | 10.0.0.30 | Windows tasks, testing | Windows 11 | 32GB |
| **pi** | 10.0.0.40 | IoT, monitoring, lightweight tasks | Arch Linux ARM | Raspberry Pi 5, 8GB |

---

## How to Set It Up

### Step 1: Generate an SSH Key

Do this on every machine. One key per machine.

```bash
ssh-keygen -t ed25519 -C "bcloud@strix-halo"
```

- Hit enter for default path (`~/.ssh/id_ed25519`)
- No passphrase (these are internal LAN machines)
- This creates two files:
  - `~/.ssh/id_ed25519` — your private key (never leaves this machine)
  - `~/.ssh/id_ed25519.pub` — your public key (goes to every other machine)

### Step 2: Copy Your Public Key to Every Other Machine

From the new machine, send your key to all existing nodes:

```bash
# From strix-halo, copy key to all others
ssh-copy-id bcloud@10.0.0.20   # sliger
ssh-copy-id bcloud@10.0.0.25   # ryzen
ssh-copy-id bcloud@10.0.0.40   # pi
```

It'll ask for the password once per machine. After that, password-free forever.

Then from each existing node, copy THEIR key back to the new machine:

```bash
# From ryzen, copy key to strix-halo
ssh-copy-id bcloud@10.0.0.10
```

Repeat until every machine has every other machine's public key in `~/.ssh/authorized_keys`.

### Step 3: Create the SSH Config

Put this in `~/.ssh/config` on every machine:

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

Host minisforum
    HostName 10.0.0.30
    User bcloud
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

Host pi pi5
    HostName 10.0.0.40
    User bcloud
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

Now instead of `ssh bcloud@10.0.0.25`, you just type `ssh ryzen`. That's it.

### Step 4: Lock Down sshd

On every Linux machine, edit `/etc/ssh/sshd_config`:

```bash
# Key-only. No passwords. No root. No exceptions.
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
```

Restart sshd:

```bash
sudo systemctl restart sshd
```

*"You shall not pass." — without a key.*

### Step 5: Verify the Mesh

From any machine, test every connection:

```bash
ssh strix-halo "hostname && uname -r"
ssh sliger "hostname && uname -r"
ssh ryzen "hostname && uname -r"
ssh pi "hostname && uname -r"
```

If all four respond, you have a full mesh. Every machine can reach every other machine by name.

---

## Windows Machines (Minisforum)

Windows OpenSSH is different. The authorized_keys file for admin users lives at:

```
C:\ProgramData\ssh\administrators_authorized_keys
```

**NOT** `~/.ssh/authorized_keys`. Windows ignores the home directory file for admin accounts.

To set it up:

```powershell
# On Windows — run as Administrator
# Enable OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

# Add your Linux machines' public keys
# Copy each machine's id_ed25519.pub content into:
notepad C:\ProgramData\ssh\administrators_authorized_keys
```

Make sure the file permissions are correct:

```powershell
icacls "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "SYSTEM:F" /grant "Administrators:F"
```

---

## What You Can Do With the Mesh

### Run Commands Remotely

```bash
# Check GPU temp on strix-halo from ryzen
ssh strix-halo "rocm-smi --showtemp"

# Check Minecraft server on sliger
ssh sliger "systemctl status minecraft"

# Reboot the pi
ssh pi "sudo reboot"
```

### SSHFS — Mount Remote Directories

Mount another machine's files as a local folder:

```bash
# Mount strix-halo's models directory on ryzen
mkdir -p ~/remote/strix-models
sshfs strix-halo:/home/bcloud/models ~/remote/strix-models
```

For permanent mounts, add to `/etc/fstab`:

```
bcloud@strix-halo:/home/bcloud/models /home/bcloud/remote/strix-models fuse.sshfs defaults,_netdev,reconnect,allow_other 0 0
```

### SSH Tunnels — Access Services Remotely

Forward a port from another machine to your local:

```bash
# Access strix-halo's Lemonade from ryzen
ssh -L 13305:localhost:13305 strix-halo

# Now open http://localhost:13305 on ryzen — you're talking to strix-halo
```

### Sync Files Between Machines

```bash
# Sync models from strix-halo to ryzen
rsync -avz strix-halo:~/models/ ~/models/

# Brain sync (Claude memory — already automated every 5 min)
~/.local/bin/claude-brain-sync.sh
```

### Deploy to All Machines at Once

```bash
# Push a script to all Linux machines
for host in strix-halo ryzen sliger pi; do
    scp my-script.sh $host:~/
    ssh $host "chmod +x ~/my-script.sh && bash ~/my-script.sh"
done
```

---

## Automated Services Over the Mesh

These run automatically on halo-ai-core:

| Service | What it does | Frequency |
|---------|-------------|-----------|
| **claude-brain-sync** | Syncs Claude memory between strix-halo ↔ ryzen | Every 5 min |
| **halo-snapshot** | btrfs snapshot rotation on all Linux machines | Daily 4am, Weekly Sun 3am |
| **halo-autoload** | Loads LLM + voice models on boot | On boot |

---

## Adding a New Machine

1. Install Arch (or whatever OS)
2. Create the `bcloud` user
3. Generate an ed25519 key
4. Copy its public key to all existing machines
5. Copy all existing machines' public keys to it
6. Add the SSH config with all hostnames
7. Lock down sshd (key-only, no root, no passwords)
8. Test from every machine

Or use the bootstrap script:

```bash
scp -r mesh-bootstrap/ bcloud@<new-ip>:~/
ssh bcloud@<new-ip> "sudo bash ~/mesh-bootstrap/bootstrap.sh"
```

---

## Security

- **Ed25519 keys only** — no RSA, no ECDSA, no passwords
- **No root login** — ever
- **No password auth** — disabled on all machines
- **LAN only** — mesh runs on 10.0.0.0/24, not exposed to internet
- **WireGuard for remote** — access from outside goes through the VPN, not direct SSH
- **Key rotation** — if a machine is compromised, regenerate all keys

*"Trust no one." — Fox Mulder. But trust your keys.*

---

## Troubleshooting

**"Permission denied (publickey)"**
- Your public key isn't in the remote machine's `authorized_keys`
- Run `ssh-copy-id bcloud@<ip>` again
- Check permissions: `chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys`

**"Connection refused"**
- sshd isn't running: `sudo systemctl start sshd`
- Firewall blocking port 22: `sudo ufw allow 22` or check firewalld

**"Host key verification failed"**
- Machine was reinstalled. Remove the old key: `ssh-keygen -R <hostname>`

**Windows SSH not working**
- Check `C:\ProgramData\ssh\administrators_authorized_keys` (NOT `~/.ssh/`)
- Run `icacls` to fix permissions
- Restart sshd: `Restart-Service sshd`

---

*"Designed and built by the architect."*
