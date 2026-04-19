# halo — the halo-ai package-manager CLI

`halo` is a single-file bash CLI that lets you manage every halo-ai component
without re-running the monolithic `install.sh`. Pattern: `pacman` + `brew` +
`systemctl`. Terse, composable, read-only commands safe, write commands
announce themselves.

## Install

`install.sh` drops a symlink; if you already have the repo checked out you can
wire it up by hand:

```bash
sudo ln -sf "$HOME/halo-ai-core/bin/halo" /usr/local/bin/halo
halo help
```

The CLI lives at `halo-ai-core/bin/halo`. Keep it there and always edit the
source, not the symlink.

## Commands

### `halo status`
One line per service + one line per timer. Columns: state, listening port,
scope (user / system), unit name. Green dot = active, yellow = active but
expected port is not listening, red = failed, open circle = inactive /
missing.

### `halo logs <service> [--follow|-f] [-n LINES]`
Thin wrapper around `journalctl -u halo-<service>`. Automatically picks the
right scope (`--user` when the unit is user-systemd, otherwise system). `-n`
defaults to 200 lines. `--follow` streams (`exec`s journalctl, so Ctrl-C
exits cleanly).

### `halo restart <service>`
`systemctl restart halo-<service>`. Uses `sudo` only when the unit is
system-scope.

### `halo update [--no-build] [--no-restart]`
Runs `git pull --ff-only` in each of:

- `~/halo-ai-core`
- `~/repos/rocm-cpp`
- `~/repos/agent-cpp`

If `agent-cpp` changes, it runs `cmake --build ... -j` and restarts
`halo-agent`. `rocm-cpp` rebuilds are **not** wired in yet — see "Open
Questions" below.

### `halo bench`
`exec`s `halo-ai-core/bench.sh`. Forwards arguments. Results land in
`benchmarks/<model>/results/`. The `anvil` timer posts summaries to Discord
separately; this command only benches.

### `halo doctor`
Full-stack health probe. Checks:

- GPU arch (`rocminfo`)
- Every halo service's port (is it actually listening?)
- Caddy reverse proxy (`https://<host>.local/` reachable)
- Headscale + tailscale (mesh still up?)
- Pi archive reachable at `100.64.0.4`
- User timers still active
- `halo-1bit-2b.h1b` model present

Exits non-zero if any `fails` are logged; warnings don't fail the command.

### `halo version`
Prints the CLI version, hostname, and short git SHA + branch for
halo-ai-core, rocm-cpp, and agent-cpp. Also lists which halo binaries are
on `$PATH`.

### `halo help [command]`
Top-level help, or per-command help if a topic is passed.

### Stubbed commands (v0.1)

- `halo install <component>` — coming soon
- `halo uninstall <component>` — coming soon (the unified `uninstall.sh`
  is still authoritative)
- `halo list` — partial: prints the known services + their current state

## Service map

| service | unit | port | scope |
|---|---|---|---|
| bitnet  | halo-bitnet.service  | 8080 | user |
| sd      | halo-sd.service      | 8081 | user |
| whisper | halo-whisper.service | 8082 | user |
| kokoro  | halo-kokoro.service  | 8083 | user |
| agent   | halo-agent.service   | —    | user |
| archive | halo-archive.service | —    | user (timer-driven) |

| timer | unit |
|---|---|
| anvil         | halo-anvil.timer        |
| gh-trio       | halo-gh-trio.timer      |
| memory-sync   | halo-memory-sync.timer  |
| archive-timer | halo-archive.timer      |

Note: as of 2026-04-19 the services have been migrated to user-systemd.
`halo` will still find them if they move back to system-scope — the lookup
tries `--user` first, then falls back to system.

## Why bash, not C++?

Per project Rule B (C++20 by default for new components): that rule covers
**runtime** code (inference path, kernels, services). `halo` is an
ops/admin front-end that only runs at user command, never in the inference
path. Keeping it in bash means:

- no build step; the user can `vim /usr/local/bin/halo` and edit it live
- sub-commands can delegate to existing shell scripts (`bench.sh`,
  `halo-anvil.sh`) without marshalling
- easy to audit (single file, no library graph)

## Open questions / punchlist

- **rocm-cpp rebuild on `halo update`** — do we `cmake --build build -j`
  here, or delegate to the `anvil` timer (which already watches rocm-cpp,
  builds, benches, and posts to Discord)? The current version prints a
  warning and does nothing; the intent is to leave this question open for
  the architect to answer.
- **`halo install <comp>` / `halo uninstall <comp>`** — needs a manifest
  describing what each component owns. Probably `release/components.toml`
  with file lists + unit names. Scoped for v0.2.
- **Caddy health probe** — currently just checks TLS reachability; doesn't
  verify `Bearer` auth flow. Good enough for `doctor`.

## Quick reference card

```
halo status                    # one-line-per-service + timers
halo logs bitnet -f            # tail bitnet_decode journal
halo logs agent -n 500         # last 500 lines, no follow
halo restart sd                # bounce halo-sd
halo update                    # git pull + rebuild + restart
halo bench                     # burn-suite
halo doctor                    # full health check
halo version                   # CLI + component SHAs
halo help update               # per-command help
```
