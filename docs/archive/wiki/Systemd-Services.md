# Systemd Services

Every service in Halo AI Core runs as a systemd unit. No custom process managers. No Docker. No supervisord. Just systemd.

## Core Services

| Service | Unit File | Port | Description |
|---------|-----------|------|-------------|
| Caddy | `caddy.service` | 80 | Reverse proxy |
| llama.cpp | `llama-server.service` | 8080 | LLM inference |
| Lemonade | `lemonade.service` | 13305 | AMD AI backend |
| Gaia | `gaia.service` | — | Agent framework |
| SSH | `sshd.service` | 22 | Remote access |

## Common Commands

```bash
# Check status of all core services
for svc in caddy sshd llama-server lemonade gaia; do
    echo "$svc: $(systemctl is-active $svc) / $(systemctl is-enabled $svc)"
done

# Start/stop/restart
sudo systemctl start llama-server
sudo systemctl stop llama-server
sudo systemctl restart llama-server

# View logs (live)
journalctl -u llama-server -f

# View logs (last 100 lines)
journalctl -u llama-server -n 100

# Check why something failed
systemctl status llama-server
journalctl -u llama-server --since "5 minutes ago"
```

## Creating a New Service

Every lego block gets a systemd unit:

```ini
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
```

Save to `/usr/lib/systemd/system/myservice.service`, then:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now myservice
```

## Override Without Editing

Don't edit the unit file directly. Use overrides:

```bash
sudo systemctl edit llama-server
```

This creates a drop-in that survives updates. Example — add a model path:

```ini
[Service]
ExecStart=
ExecStart=/usr/local/bin/llama-server --host 0.0.0.0 --port 8080 -m /models/qwen3.gguf --n-gpu-layers 999
```

## Auto-Restart

All services are configured with `Restart=on-failure` and `RestartSec=5`. If a service crashes, systemd brings it back within 5 seconds. Check restart history:

```bash
journalctl -u llama-server | grep "Started\|Stopped\|Failed"
```

## Watchdog Pattern

Instead of polling timers, services should detect events and react:

```ini
[Service]
# Watchdog checks every 30s
WatchdogSec=30
```

The service must send heartbeats via `sd_notify`. If it stops responding, systemd restarts it.
