# Adding a Service (Lego Block Template)

This is the step-by-step template for adding any new service to Halo AI Core. Every service follows the same pattern.

## The Pattern

Every lego block has 4 parts:

1. **The software** — install it
2. **A systemd unit** — manage it
3. **A Caddy route** (optional) — expose it
4. **Documentation** — explain it

## Step 1: Install the Software

From Arch repos (preferred):
```bash
sudo pacman -S myservice
```

From source (when needed):
```bash
git clone https://github.com/whoever/myservice.git ~/myservice
cd ~/myservice && make && sudo make install
```

From pip (in a venv, never system-wide):
```bash
~/.pyenv/versions/3.13.12/bin/python3 -m venv ~/myservice-env
~/myservice-env/bin/pip install myservice
```

### Package Priority

1. **Official Arch repos** — tried, trusted, already built
2. **AUR** — community packages, `yay -S package`
3. **Build from source** — when you need specific flags
4. **Pip in venv** — Python packages, never `--break-system-packages`
5. **Flatpak** — last resort

## Step 2: Create systemd Unit

```bash
sudo tee /usr/lib/systemd/system/myservice.service > /dev/null << 'EOF'
[Unit]
Description=My Service
After=network.target

[Service]
Type=simple
User=bcloud
Environment=PATH=/usr/local/bin:/opt/rocm/bin:/usr/bin
ExecStart=/usr/local/bin/myservice --port 9000
Restart=on-failure
RestartSec=5
WorkingDirectory=/home/bcloud

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now myservice
```

### Key Settings

| Setting | What It Does |
|---------|-------------|
| `User=bcloud` | Never run as root |
| `Restart=on-failure` | Auto-restart on crash |
| `RestartSec=5` | Wait 5s before restart |
| `After=network.target` | Start after network is up |
| `Environment=PATH=...` | Include ROCm if GPU-dependent |

## Step 3: Add Caddy Route (Optional)

Only if the service needs to be reachable through the proxy:

```bash
sudo tee /etc/caddy/conf.d/myservice.caddy > /dev/null << 'EOF'
:9001 {
    reverse_proxy localhost:9000
}
EOF
sudo systemctl reload caddy
```

## Step 4: Verify

```bash
# Service running?
systemctl status myservice

# Responding?
curl localhost:9000/health

# Through Caddy?
curl localhost:9001/health

# Logs clean?
journalctl -u myservice -n 20
```

## Step 5: Snapshot

Before and after adding any service, take a btrfs snapshot:

```bash
sudo btrfs subvolume snapshot -r / /.snapshots/before-myservice-$(date +%Y%m%d)
# ... install ...
sudo btrfs subvolume snapshot -r / /.snapshots/after-myservice-$(date +%Y%m%d)
```

If something breaks, roll back.

## Removing a Service

```bash
sudo systemctl disable --now myservice
sudo rm /usr/lib/systemd/system/myservice.service
sudo rm /etc/caddy/conf.d/myservice.caddy
sudo systemctl daemon-reload
sudo systemctl reload caddy
```

The block is out. Nothing else breaks. That's the lego philosophy.

## Replacing a Core Service

Want to swap llama.cpp for vLLM? Or Caddy for Nginx?

1. Stop the old service: `sudo systemctl disable --now llama-server`
2. Install the replacement
3. Create a new systemd unit on the same port
4. Update the Caddy route if ports changed
5. Test
6. Remove the old service files

Core services are lego blocks too. Nothing is permanent.
