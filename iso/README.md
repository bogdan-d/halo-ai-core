# iso/ — bootable live USB for halo-ai-core

Builds an Arch-based live ISO with **the entire 1-bit monster baked in**:

- rocm-hip-sdk, rocm-opencl-sdk (full ROCm runtime, pacman'd at build time)
- `bitnet_decode`, `agent_cpp`, `librocm_cpp.so` (v0.2.0 binaries from `release/dist/`)
- `halo-1bit-2b.h1b` + `.htok` (1.8 GB ternary model)
- `halo-ai-core` git tree (via `git archive HEAD`) in `/etc/skel/halo-ai-core`
- `halo-install` and `halo-bootstrap` helpers for committing the stack to a target disk
- Claude Code memory state tarball in `/etc/skel/claude-state.tar.gz` (optional)
- Node.js + npm (for `@anthropic-ai/claude-code` if the architect installs it on first boot)

Result: a bootable USB that runs the inference engine **off the stick** — no internet required, no install required. Full dev environment on the move.

## Build

```bash
# one-time: sudo pacman -S archiso
cd halo-ai-core
./release/build-release.sh          # produces the tarballs iso/stage-binaries.sh reads
./iso/build-iso.sh                  # ~20-40 min
ls iso/out/                         # halo-ai-core-YYYY.MM.DD-x86_64.iso
```

## Flash to USB

```bash
# Find the target device (NOT your boot disk!)
lsblk -d -o NAME,SIZE,MODEL | grep -v loop

# Flash — destructive
sudo dd if=iso/out/halo-ai-core-*.iso of=/dev/sdX bs=4M conv=fsync status=progress
sync
```

## Boot it

Set the target machine's BIOS to boot from USB. You land in a live root shell:

```
╔════════════════════════════════════════╗
║  halo-ai-core — the 1-bit monster      ║
║  bootable live environment             ║
╚════════════════════════════════════════╝

# rocminfo | grep gfx
gfx1151

# bitnet_decode --model /opt/halo-ai/models/halo-1bit-2b.h1b --repl
[rocm-cpp] .h1b v2: rope_theta=500000.0 rms_norm_eps=1.0e-05
> hi
Hi! How can I help you today?
```

## Commit to disk

```
# halo-install /dev/nvme0n1
wipe /dev/nvme0n1 and install halo-ai-core? type YES: YES
...
[6/6] Installed. Reboot into disk.
```

See `halo-bootstrap` for the full disk-wipe + pacstrap + systemd-boot + halo-ai-core
clone flow.

## What's IN the ISO vs what pacman fetches at build time

| baked into ISO image | fetched by mkarchiso from Arch repos |
|---|---|
| our v0.2.0 binaries + model | Arch kernel, base, base-devel |
| halo-ai-core repo archive | rocm-hip-sdk, rocm-opencl-sdk |
| Claude state (optional) | nodejs, npm, zstd, rsync |
| halo-install, halo-bootstrap | NetworkManager, systemd, openssh |
| custom motd | all other base live packages |

## Size

- Overlay (our stuff): ~1.8 GB (dominated by the .h1b model)
- ISO output (compressed squashfs): expect 4-6 GB
- Flash to: 8 GB USB minimum; 16+ GB comfortable

## Dev loop

Rebuild after code changes:
```bash
./release/build-release.sh        # new binaries in release/dist/
./iso/stage-binaries.sh           # refresh overlay (fast)
./iso/build-iso.sh                # rebuild ISO (slow)
```

`stage-binaries.sh` is idempotent and cheap. Only `build-iso.sh` is slow.

## Why an ISO

Three use cases:

1. **Ship a box** — hand someone a Strix Halo mini-PC with a USB stick; they boot, run the engine, decide whether to commit.
2. **Demo without prep** — walk into a venue with a Strix Halo laptop + this USB, boot, serve `bitnet_decode --server` on :8080, demo.
3. **Recovery** — if the installed stack breaks, boot live, grab `halo-install` or `halo-bootstrap` to re-install.
