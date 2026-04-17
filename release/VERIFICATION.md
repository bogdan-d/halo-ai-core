# Verifying halo-ai-core releases

## SHA256 (always present)

```bash
cd release-dir/
sha256sum -c SHA256SUMS
```

`install-strixhalo.sh` does this automatically before extracting anything.

## GPG signature (when present)

Import the architect's public key once:

```bash
curl https://github.com/stampby.gpg | gpg --import
```

Verify the signature:

```bash
gpg --verify SHA256SUMS.asc SHA256SUMS
```

If GPG says "Good signature from ...": the SUMS file hasn't been tampered with, the
tarballs match the SUMS, and everything came from the architect's private key.

`install-strixhalo.sh` does this automatically if `SHA256SUMS.asc` is present in the
release. Skip with `--skip-gpg` if you need to test against a dev build.

## Reproducibility (roadmap)

Goal: the same source commits + the same compiler versions produce the same binary.
Not yet achieved — llvm and rocm emit timestamps. Tracking in issue #TBD.

For now: the MANIFEST.json records the source commits of each component at build
time. If you build from those commits on a Strix Halo with the same ROCm version,
the output should be functionally identical (same PPL, same decode tokens).

## Chain of trust

```
architect's laptop (source commits, signed)
    ↓
strixhalo build box (runs build-release.sh; GPG-signs SUMS)
    ↓
github.com/stampby/halo-ai-core/releases (SHA256SUMS verifies tarball integrity)
    ↓
your Strix Halo (install-strixhalo.sh verifies before extract)
```

If any link is compromised, the next link's verification fails.
