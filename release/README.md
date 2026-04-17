# release/ — build & publish binaries

Pre-built artifacts for Strix Halo (gfx1151). Produced once on an authoritative
build machine, consumed many times by any other Strix Halo box.

## Build

```bash
# Assumes ~/rocm-cpp, ~/agent-cpp, ~/halo-1bit, ~/man-cave are checked out.
./release/build-release.sh
# → release/dist/*.tar.zst + SHA256SUMS + MANIFEST.json
```

Environment overrides:
- `VERSION=v0.2.0`       — tag / version label on the manifest
- `SIBLINGS_DIR=$HOME`   — where sibling repos live (default `$HOME`)
- `GPG_KEY=<keyid>`      — sign SHA256SUMS with this key
- `CLEAN=0`              — reuse build dirs (faster iteration)

## Publish

```bash
git tag -a v0.2.0 -m "halo-ai-core v0.2.0 — 1-bit monster"
./release/upload-release.sh --tag v0.2.0 --notes RELEASE_NOTES.md
# → https://github.com/stampby/halo-ai-core/releases/tag/v0.2.0
```

## What ships

| file | content |
|------|---------|
| `bitnet_decode-gfx1151.tar.zst`  | `bin/bitnet_decode` — rocm-cpp inference server |
| `librocm_cpp-gfx1151.tar.zst`    | `lib/librocm_cpp.so` — shared library |
| `agent_cpp.tar.zst`              | `bin/agent_cpp` — agent runtime (arch-agnostic) |
| `man-cave-gfx1151.tar.zst`       | `bin/man_cave` — FTXUI TUI dashboard |
| `halo-1bit-models-tq1_0.tar.zst` | `.h1b` model(s) + `.htok` tokenizer |
| `SHA256SUMS`                     | sha256 of every tarball |
| `SHA256SUMS.asc`                 | GPG signature of the SUMS file (if key was set) |
| `MANIFEST.json`                  | version, build time, component commits, asset sizes |

## Why pre-built on one box

Every Strix Halo is the same silicon — gfx1151, wave32 WMMA, 128 GB unified. A binary
built on one runs bit-identically on every other. Rebuilding TheRock (4 h) on every
install is wasted cycles. This is how apt, pacman, brew, and every other distro work:
build once, ship everywhere.

For non-Strix Halo users, the wave32 WMMA kernels in rocm-cpp don't translate — those
users take the `./install-source.sh` path and get arch-specific codegen.

## Verification

Every release includes a `SHA256SUMS` file. `install-strixhalo.sh` verifies before
extract. If a `SHA256SUMS.asc` is present, it's also checked against the architect's
GPG key — see `VERIFICATION.md` for the fingerprint.

## CI (future)

The `anvil` specialist in agent-cpp watches tag pushes on `main`. When a new tag
lands, it runs `build-release.sh` on a self-hosted strixhalo runner and publishes
automatically. Not yet wired.
