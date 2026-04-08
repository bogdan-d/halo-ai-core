# Lego Blocks — Add-On Services

Halo AI Core is the foundation. These are blocks you can snap on top. Each one is independent — add what you need, ignore what you don't.

## Available Blocks

### Inference & Models
| Block | What It Does | Status |
|-------|-------------|--------|
| Open WebUI | Chat frontend for llama.cpp | Planned |
| ComfyUI | Image/video generation | Planned |
| Whisper | Speech-to-text | Via Lemonade |
| Kokoro TTS | Text-to-speech | Via Lemonade |
| vLLM | Production inference server | Optional |

### Infrastructure
| Block | What It Does | Status |
|-------|-------------|--------|
| SSH Mesh | Multi-machine key mesh | Available |
| GlusterFS | Distributed storage | Planned |
| SearXNG | Private search engine | Planned |
| Pi-hole | Network ad blocking | Planned |
| DDNS | Dynamic DNS for remote access | Planned |

### Applications
| Block | What It Does | Status |
|-------|-------------|--------|
| Arcade | Game server management | Planned |
| Discord Bots | AI agent bots | Planned |
| Voice Pipeline | Full voice in/out | Planned |
| Landing Page | Web dashboard | Planned |

### Security
| Block | What It Does | Status |
|-------|-------------|--------|
| Sentinel | Security monitoring agent | Planned |
| Fail2ban | SSH brute force protection | Planned |
| Audit logs | systemd journal analysis | Planned |

## Building Your Own Block

A lego block is just:

1. A service that runs on a port
2. A systemd unit file
3. A Caddy drop-in config (optional)
4. An install section in a script

Example:

```bash
# 1. Install your thing
sudo pacman -S myservice

# 2. Create systemd unit
sudo tee /usr/lib/systemd/system/myservice.service > /dev/null << 'EOF'
[Unit]
Description=My Service
After=network.target

[Service]
Type=simple
User=bcloud
ExecStart=/usr/bin/myservice --port 9000
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 3. Add Caddy route (optional)
sudo tee /etc/caddy/conf.d/myservice.caddy > /dev/null << 'EOF'
:9001 {
    reverse_proxy localhost:9000
}
EOF

# 4. Enable
sudo systemctl daemon-reload
sudo systemctl enable --now myservice
sudo systemctl reload caddy
```

That's it. Your block is live.
