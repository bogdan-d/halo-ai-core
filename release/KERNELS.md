# Want the kernels built for your GPU?

This release ships **gfx1151-only** pre-built binaries (Strix Halo / Radeon 8060S).
Every other AMD GPU needs its own kernel build. Here's how to make that happen.

## The short version

If you run a GPU other than gfx1151, use `install-source.sh` — it builds rocm-cpp
from source against your silicon:

```bash
git clone https://github.com/stampby/halo-ai-core.git
cd halo-ai-core
./install-source.sh
```

`install-source.sh` auto-detects your GPU arch via `rocminfo` and passes it to
CMake. The heavy build is TheRock (~3-4 h on first run); rocm-cpp + agent-cpp on
top are under 10 minutes.

## What the architect supports vs what you build yourself

| arch | family | status | path |
|------|--------|--------|------|
| **gfx1151** | Strix Halo, Radeon 8060S | official pre-built | `install-strixhalo.sh` |
| gfx1150 | Strix Point (close cousin) | should cross-compile | `install-source.sh` |
| gfx1100 | RX 7900 XTX/XT, 7800 XT, W7900 (RDNA3) | community builds welcome | `install-source.sh` |
| gfx1101 | RX 7700 XT (RDNA3) | community builds welcome | `install-source.sh` |
| gfx1030 | RX 6900 XT, 6800 XT (RDNA2) | no wave32 WMMA — kernels need rewrite | TBD |
| gfx1200 | Navi 44 (9060 / 9060 XT) | wmma-512b — kernel port needed | TBD |
| gfx1201 | Navi 48 (9070 / 9070 XT) | wmma-512b — kernel port needed | TBD |
| gfx908 / gfx90a / gfx942 | MI100 / MI200 / MI300 (CDNA) | wave64 — different kernel family | TBD |

The "TBD" rows are not impossible — just not written yet. See "contributing a kernel
path" below.

## Submitting your build back (community release)

Built rocm-cpp successfully on an arch the architect hasn't? Here's how to share
it without blocking on a merge:

1. **Build it cleanly with the release pipeline.**

```bash
# On a box with your GPU + ROCm installed:
git clone https://github.com/stampby/halo-ai-core.git && cd halo-ai-core
HIP_ARCHES=<your-arch> ./release/build-release.sh
ls release/dist/                                     # should see 4 tarballs
```

2. **Sign the `SHA256SUMS`** with your GPG key:

```bash
gpg --detach-sign --armor --default-key <your-keyid> release/dist/SHA256SUMS
```

3. **Upload** somewhere you control (your own GitHub Releases, an S3 bucket, a
   static site) — not a random pastebin. Users should be able to audit.

4. **Open an issue on halo-ai-core** linking your release, your keyid, and the
   exact build command. The architect will add a row to this file pointing users
   at your build under "community". We do NOT promote community builds to the
   official release — the chain of trust is yours, not ours.

## Contributing a kernel path

If your arch isn't in the table above (or is TBD) and you want to add it, the
kernels live in `rocm-cpp/src/*.hip` and `rocm-cpp/kernels/*.hip`. The fused
ternary path uses these RDNA3.5 builtins:

- `__builtin_amdgcn_wmma_f32_16x16x16_f16_w32` — wmma-256b, wave32
- `__builtin_amdgcn_ds_swizzle_b32` — cross-lane, wave32

RDNA4 (gfx1200/1201) has `wmma_*_w32` intrinsics too but in a different encoding
(`wmma-512b-insts`). The port mainly means arch-gated builtin selection.

RDNA2 (gfx1030) has no native WMMA — you'd need to fall back to `v_dot4_i8_i8`
DP4A on ternary inputs. Slower, but viable.

CDNA (MI-series) is wave64 and uses a completely different MFMA family. That's a
new kernel, not a port.

Open a draft PR on rocm-cpp when you have a build that passes `tests/test_standalone`
on your arch; architect will review.

## License

Everything ships MIT. No signing key rotation. No restrictions on redistribution.
If you want to ship a fork, ship it.
