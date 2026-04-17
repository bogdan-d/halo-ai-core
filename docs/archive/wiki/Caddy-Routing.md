# Caddy Routing

Caddy is the gateway to everything. All services bind to `localhost` — Caddy is the only thing that could talk to the outside.

## How It Works

Main config at `/etc/caddy/Caddyfile`:

```
:80 {
    respond "halo-ai core — {hostname}"
}

import /etc/caddy/conf.d/*.caddy
```

The `import` line loads every `.caddy` file from the drop-in directory. Add a service, drop a config, reload. Done.

## Adding a Route

```bash
sudo tee /etc/caddy/conf.d/myservice.caddy > /dev/null << 'EOF'
:9001 {
    reverse_proxy localhost:9000
}
EOF
sudo systemctl reload caddy
```

That's it. Port 9001 now proxies to your service on 9000.

## Current Routes

| External Port | Internal Target | Service |
|--------------|-----------------|---------|
| :80 | — | Landing page |
| :8081 | localhost:8080 | llama.cpp |
| :13306 | localhost:13305 | Lemonade |

## Path-Based Routing

Instead of separate ports, route by path:

```
:80 {
    handle /api/llm/* {
        reverse_proxy localhost:8080
    }
    handle /api/lemonade/* {
        reverse_proxy localhost:13305
    }
    respond "halo-ai core"
}
```

## Validation

Always validate before reloading:

```bash
caddy validate --config /etc/caddy/Caddyfile
```

## Logs

```bash
journalctl -u caddy -f
```

## Why Caddy

- Drop-in config pattern (no monolithic nginx.conf)
- Automatic HTTPS when needed
- Simple syntax
- Hot reload without downtime
