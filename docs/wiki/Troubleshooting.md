# Troubleshooting

Common failures and their fixes, ranked by how often they come up.

## Install

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

`halo-bitnet.service` isn't running:

```bash
systemctl status halo-bitnet
# If failed, see logs:
journalctl -u halo-bitnet -n 30
```

Common causes:
- Model file missing: check `/home/bcloud/halo-ai/models/halo-1bit-2b.h1b`
  exists (should be 1.8 GB). Re-extract from the release tarball if not.
- Port 8080 already in use: change the unit's ExecStart to `--server 8081`

### `model not found` / HTTP 400

The model id must be exactly `bitnet-b1.58-2b-4t`. Anything else → reject.

### Very slow first token

Cold cache. First request loads the 1.8 GB model into GPU memory (~1-2 s on
Strix Halo). Subsequent requests hit ~85 tok/s steady-state.

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
sudo systemctl restart halo-bitnet
```

### Kernel panic / hang under load

Known Strix Halo quirk with some kernel versions. Use mainline 7.0+ or the
CachyOS `linux-cachyos` kernel — both tested working.

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

## If all else fails

1. Check [buglog.json](https://github.com/stampby/halo-ai-core/blob/main/.wolf/buglog.json)
   for known fixes.
2. Look at the session log at `$XDG_STATE_HOME/agent-cpp/sessions/` — the
   hash-chained JSONL has every routed message, including errors.
3. File an issue: https://github.com/stampby/halo-ai-core/issues/new

The quartermaster specialist will auto-triage it. A human will follow up.
