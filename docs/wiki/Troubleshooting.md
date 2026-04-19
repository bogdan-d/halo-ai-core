# Troubleshooting

Common failures and their fixes, ranked by how often they come up.
Private-mesh / Headscale / Caddy issues: jump to [Networking](#networking) below.

## Install

### "NPU not detected" / `amdxdna` driver missing / agent falls back to iGPU

You're not on **[CachyOS](https://cachyos.org/)**. The XDNA2 NPU on Strix
Halo only works correctly on CachyOS — stock Arch, Ubuntu, Fedora, Debian,
EndeavourOS, Manjaro either miss the `amdxdna` kernel patches or ship an
older driver that silently falls back to CPU/iGPU. Check:

```bash
lspci -k | grep -A3 amdxdna       # should show driver bound
uname -r                          # should be 7.0.0-cachyos or newer
```

If `amdxdna` isn't bound or you're not on a `*-cachyos` kernel, **install
CachyOS before continuing**. The GPU path (`rocm-cpp`) technically works on
stock Arch but you lose the NPU specialists (`echo_ear`, lemond-FLM backends)
and several `bench.sh` benchmarks.

### `rocminfo: command not found` / `hipcc: command not found`

ROCm isn't installed. `install-strixhalo.sh` runs `pacman -S rocm-hip-sdk`
on step 2; if it was skipped or pacman failed:

```bash
sudo pacman -S --needed rocm-hip-sdk rocm-opencl-sdk
```

### `checksum verification FAILED`

The downloaded release asset doesn't match the SHA256SUMS. Either:
- GitHub returned a partial download (network flaked) → re-run install
- Release was tampered with → report + verify against
  https://github.com/stampby/halo-ai-core/releases/tag/v0.2.1

### `zstd: /*stdin*: unsupported format`

Rare. Means `tar --zstd` tried to decompress a non-zstd file — usually a 404
HTML body saved as `.tar.zst`. Fixed in commits `ebd76dd` + `67ca511` which
force `curl -f` (hard fail, no body on error). If you see this on a current
install, `git pull` first.

### `gfx1151 not detected`

`rocminfo` not finding the GPU. Check:

```bash
lsmod | grep amdgpu               # driver loaded?
dmesg | grep amdgpu | tail -5     # any errors?
rocminfo | grep 'Name:' | head    # what does it see?
```

If you're sure it's a Strix Halo and detection just fails: `GPU_ARCH=gfx1151
./install-strixhalo.sh`.

## Runtime

### `connection refused` on :8080

`halo-bitnet.service` isn't running. Since 2026-04-19 every halo unit is
user-scope (lives in `~/.config/systemd/user/`):

```bash
systemctl --user status halo-bitnet
# or use the unified CLI:
halo status
halo logs bitnet -n 30

# Fallback: read the journal directly
journalctl --user -u halo-bitnet -n 30
```

Common causes:
- Model file missing: check `/home/bcloud/halo-ai/models/halo-1bit-2b.h1b`
  exists (should be ~1.1 GiB in TQ1_0 packing). Re-extract from the release
  tarball if not.
- Port 8080 already in use: change the unit's ExecStart to `--server 9080`
  (avoid 8081/8082/8083 — those are halo-sd / halo-whisper / halo-kokoro)

### `model not found` / HTTP 400

The model id must be exactly `bitnet-b1.58-2b-4t`. Anything else → reject.

### Very slow first token

Cold cache. First request mmaps the ~1.1 GiB model into GPU-visible memory
(< 2 s on Strix Halo). Subsequent requests hit ~83 tok/s @ 64 ctx (68.6 @ 1024) steady-state.

### agent-cpp exits immediately

This was a bug in v0.2.0 — fixed in v0.2.1 with headless-mode autodetection.
If you installed v0.2.0, either:
- Upgrade: `./install-strixhalo.sh --tag v0.2.1`
- Or set `AGENT_CPP_HEADLESS=1` in the systemd unit's Environment= line

### empty or garbage LLM output

Check temperature + sampling. The default is `temperature=0.7, top_p=0.9`. If
you passed `temperature=0.0`, BitNet will sometimes loop. Try `temperature=0.3`
+ `repetition_penalty=1.1` via extra params.

## GPU / driver

### `HSA_STATUS_ERROR_OUT_OF_RESOURCES`

VRAM is full. Two processes fighting for GPU memory, or a previous crash
left state behind. Restart:

```bash
systemctl --user restart halo-bitnet
# or
halo restart bitnet
```

### Kernel panic / hang under load

Known Strix Halo quirk with some kernel versions. Use mainline 7.0+ or the
CachyOS `linux-cachyos` kernel — both tested working.

## Satellite services (halo-sd / halo-whisper / halo-kokoro)

All three are user-systemd units on 8081/8082/8083 respectively. Common drift:

```bash
halo status                                 # one-line-per-service summary
halo logs sd -f                             # tail halo-sd
halo logs kokoro -n 200                     # last 200 lines from Bun shim
systemctl --user restart halo-whisper
```

- `halo-sd` failing to load model → check `~/halo-ai/models/sdxl/` exists and
  is populated. The service probes for the model at startup and refuses to
  bind if weights are missing.
- `halo-kokoro` crash-looping under Bun → verify `HALO_KOKORO_BIN` points at
  the native `kokoro_tts` binary (unit environment) and `bun --version`
  resolves (`pacman -Q bun`).
- `/sd/*` returning 401 through Caddy → Caddy bearer gate is separate from the
  service auth; token lives in `/etc/caddy/token.secret`.

## Discord (if sentinel/herald enabled)

### sentinel starts but polls nothing

Check:

```bash
echo $DISCORD_TOKEN | head -c 10    # should start with Bot or MTA...
echo $DISCORD_WATCH_CHANNELS         # comma-separated channel IDs
```

Tokens must be bot tokens (not user tokens); channels must be numeric IDs
(right-click channel → Copy ID, requires Developer Mode enabled in your
Discord client).

### herald posts fail with HTTP 403

Bot doesn't have `Send Messages` permission in that channel, or isn't a
guild member. Invite bot with scope `bot` + `Send Messages`, `Read Message
History` permissions at minimum.

## GitHub (if quartermaster/magistrate/librarian enabled)

### HTTP 401 from GitHub API calls

`GH_TOKEN` missing or expired. Generate a new classic PAT at
https://github.com/settings/tokens with `repo` scope. Update the systemd
unit's `Environment=GH_TOKEN=ghp_...`.

### HTTP 403 "secondary rate limit"

GitHub rate-limited the app. The specialists don't currently handle 403
retry-after; fix pending. Wait 5 min and it clears.

## Networking

See **[NETWORKING.md](../NETWORKING.md)** for the full stack walkthrough.
Ranked common failures:

### `x509: certificate signed by unknown authority` — on a peer trying to join

The peer hasn't trusted the halo box's local CA. Fix:

```bash
sudo curl -fsSL http://<halo-lan-ip>:8099/halo-local.crt \
  -o /etc/ca-certificates/trust-source/anchors/halo-local.crt
sudo trust extract-compat && sudo update-ca-trust
sudo systemctl restart tailscaled
```

The `join.sh` bootstrap does this automatically for Arch-family peers. For
Ubuntu/Debian peers use `/usr/local/share/ca-certificates/halo-local.crt` and
`sudo update-ca-certificates` instead.

### `Failed to connect to 10.0.0.10 port 8099`

UFW is blocking the bootstrap port. `install-strixhalo.sh` adds an allow rule
for the detected `/24`, but if your peer is on a different subnet:

```bash
sudo ufw allow from <peer-subnet>/24 to any port 8099 proto tcp
sudo ufw reload
```

### `preauth key expired`

Keys default to 24h reusable. Regenerate:

```bash
sudo headscale preauthkeys create -u 1 --reusable --expiration 24h
```

Then reprint the QR / join one-liner or update the mobile onboarding page at
`/var/www/halo-bootstrap/m.html`.

### `halo-bitnet.service` returns 401 even with the right token

Caddy's bearer regex in `/etc/caddy/Caddyfile` includes the token verbatim.
If you regenerated `/etc/caddy/token.secret`, you have to rewrite the Caddyfile
(or re-run the relevant block of `install-strixhalo.sh`). Restart with
`sudo systemctl restart caddy`.

### `MagicDNS warnings` on the halo box (systemd-resolved/NetworkManager)

Benign — Arch's resolved + NM wiring can confuse tailscale's MagicDNS probe.
Names in `*.ts.net` may not resolve locally; the tailnet IPs always work. If
MagicDNS actually fails and you need hostnames, add entries to `/etc/hosts`
on each peer, or run `sudo resolvectl dns tailscale0 100.100.100.100`.

### `Main process exited, code=dumped, status=11/SEGV` on bitnet_decode

Historical — fixed in rocm-cpp commit `8f764d7`. If you're on an older binary,
update with `install-strixhalo.sh --tag latest`.

## If all else fails

1. Check [buglog.json](https://github.com/stampby/halo-ai-core/blob/main/.wolf/buglog.json)
   for known fixes.
2. Look at the session log at `$XDG_STATE_HOME/agent-cpp/sessions/` — the
   hash-chained JSONL has every routed message, including errors.
3. File an issue: https://github.com/stampby/halo-ai-core/issues/new

The quartermaster specialist will auto-triage it. A human will follow up.
