#!/usr/bin/env bash
# halo-ai-core release/build-release.sh — bake the Strix Halo binaries.
#
# Produces the tarballs that install-strixhalo.sh downloads:
#
#   release/dist/bitnet_decode-gfx1151.tar.zst     — the inference server binary
#   release/dist/librocm_cpp-gfx1151.tar.zst       — the shared lib
#   release/dist/agent_cpp.tar.zst                 — the agent runtime (arch-agnostic)
#   release/dist/man-cave-gfx1151.tar.zst          — FTXUI TUI
#   release/dist/halo-1bit-models-tq1_0.tar.zst    — .h1b model + tokenizer
#   release/dist/SHA256SUMS                        — hashes of the above
#   release/dist/SHA256SUMS.asc                    — GPG sig (if key available)
#   release/dist/MANIFEST.json                     — metadata (sizes, commits, build time)
#
# Assumes rocm-cpp, agent-cpp, halo-1bit checked out at siblings to halo-ai-core.
# Does a clean build of each so the binaries match the committed source exactly.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$ROOT/release/dist"
STAGE="$ROOT/release/stage"
VERSION="${VERSION:-$(git -C "$ROOT" describe --tags --always 2>/dev/null || echo dev)}"

SIBLINGS_DIR="${SIBLINGS_DIR:-$HOME}"
ROCMCPP="${ROCMCPP:-$SIBLINGS_DIR/rocm-cpp}"
AGENTCPP="${AGENTCPP:-$SIBLINGS_DIR/agent-cpp}"
HALO1BIT="${HALO1BIT:-$SIBLINGS_DIR/halo-1bit}"
MANCAVE="${MANCAVE:-$SIBLINGS_DIR/man-cave}"

GPG_KEY="${GPG_KEY:-}"   # empty = skip signing
CLEAN="${CLEAN:-1}"      # 1 = fresh build dirs

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()  { echo -e "${CYAN}[build-release]${NC} $1"; }
ok()   { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
die()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }

rm -rf "$DIST" "$STAGE"
mkdir -p "$DIST" "$STAGE"

# ── rocm-cpp — bitnet_decode + librocm_cpp ──────────────────
log "building rocm-cpp @ $ROCMCPP"
[[ -d "$ROCMCPP" ]] || die "rocm-cpp not found at $ROCMCPP"
(
    cd "$ROCMCPP"
    [[ "$CLEAN" == "1" ]] && rm -rf build
    cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_HIP_ARCHITECTURES=gfx1151 >/dev/null
    cmake --build build -j$(nproc) --target bitnet_decode rocm_cpp 2>&1 | tail -3
)
mkdir -p "$STAGE/rocm-cpp/bin" "$STAGE/rocm-cpp/lib"
cp "$ROCMCPP/build/bitnet_decode"    "$STAGE/rocm-cpp/bin/"
cp "$ROCMCPP/build/librocm_cpp.so"   "$STAGE/rocm-cpp/lib/" 2>/dev/null || \
  cp "$ROCMCPP/build/librocm_cpp.a"  "$STAGE/rocm-cpp/lib/" 2>/dev/null || \
  warn "librocm_cpp not found in build — bitnet_decode may be linked statically"
strip --strip-unneeded "$STAGE/rocm-cpp/bin/bitnet_decode" || true
strip --strip-unneeded "$STAGE/rocm-cpp/lib/"*.so 2>/dev/null || true

tar --zstd -cf "$DIST/bitnet_decode-gfx1151.tar.zst" -C "$STAGE/rocm-cpp" bin/
if [[ -f "$STAGE/rocm-cpp/lib/librocm_cpp.so" ]]; then
    tar --zstd -cf "$DIST/librocm_cpp-gfx1151.tar.zst" -C "$STAGE/rocm-cpp" lib/
fi
ok "rocm-cpp packaged"

# ── agent-cpp — agent_cpp (arch-agnostic — pure C++) ────────
log "building agent-cpp @ $AGENTCPP"
[[ -d "$AGENTCPP" ]] || die "agent-cpp not found at $AGENTCPP"
(
    cd "$AGENTCPP"
    [[ "$CLEAN" == "1" ]] && rm -rf build
    cmake -B build -DCMAKE_BUILD_TYPE=Release >/dev/null
    cmake --build build -j$(nproc) --target agent_cpp 2>&1 | tail -3
)
mkdir -p "$STAGE/agent-cpp/bin"
cp "$AGENTCPP/build/agent_cpp" "$STAGE/agent-cpp/bin/"
strip --strip-unneeded "$STAGE/agent-cpp/bin/agent_cpp" || true
tar --zstd -cf "$DIST/agent_cpp.tar.zst" -C "$STAGE/agent-cpp" bin/
ok "agent-cpp packaged"

# ── man-cave — FTXUI TUI (optional) ─────────────────────────
if [[ -d "$MANCAVE" && -f "$MANCAVE/CMakeLists.txt" ]]; then
    log "building man-cave @ $MANCAVE"
    (
        cd "$MANCAVE"
        [[ "$CLEAN" == "1" ]] && rm -rf build
        cmake -B build -DCMAKE_BUILD_TYPE=Release >/dev/null
        cmake --build build -j$(nproc) 2>&1 | tail -3
    )
    mkdir -p "$STAGE/man-cave/bin"
    find "$MANCAVE/build" -maxdepth 2 -type f -executable -name "man*" \
         -exec cp {} "$STAGE/man-cave/bin/" \; 2>/dev/null || true
    if compgen -G "$STAGE/man-cave/bin/*" > /dev/null; then
        strip --strip-unneeded "$STAGE/man-cave/bin/"* 2>/dev/null || true
        tar --zstd -cf "$DIST/man-cave-gfx1151.tar.zst" -C "$STAGE/man-cave" bin/
        ok "man-cave packaged"
    else
        warn "man-cave binary not found — skipping"
    fi
else
    warn "man-cave dir not found at $MANCAVE — skipping"
fi

# ── halo-1bit models ────────────────────────────────────────
log "packaging halo-1bit models"
[[ -d "$HALO1BIT/models" ]] || die "halo-1bit models not found at $HALO1BIT/models"
mkdir -p "$STAGE/models"
shopt -s nullglob
for f in "$HALO1BIT"/models/*.h1b "$HALO1BIT"/models/*.htok "$HALO1BIT"/tokenizer.htok; do
    [[ -f "$f" ]] && cp "$f" "$STAGE/models/"
done
shopt -u nullglob
# prefer the absmean flavor as the ship default
if [[ -f "$STAGE/models/halo-1bit-2b-absmean.h1b" ]]; then
    mv "$STAGE/models/halo-1bit-2b-absmean.h1b" "$STAGE/models/halo-1bit-2b.h1b"
fi
tar --zstd -cf "$DIST/halo-1bit-models-tq1_0.tar.zst" -C "$STAGE" models/
ok "halo-1bit models packaged"

# ── SHA256SUMS ──────────────────────────────────────────────
log "computing SHA256SUMS"
(cd "$DIST" && sha256sum *.tar.zst > SHA256SUMS)
ok "SHA256SUMS written"

# ── GPG sign ────────────────────────────────────────────────
if [[ -n "$GPG_KEY" ]] && command -v gpg &>/dev/null; then
    log "signing SHA256SUMS with GPG key $GPG_KEY"
    gpg --detach-sign --armor --default-key "$GPG_KEY" -o "$DIST/SHA256SUMS.asc" "$DIST/SHA256SUMS"
    ok "SHA256SUMS.asc written"
else
    warn "GPG_KEY not set — skipping signature (set GPG_KEY=<keyid> to enable)"
fi

# ── MANIFEST.json ───────────────────────────────────────────
log "writing MANIFEST.json"
{
    echo "{"
    echo "  \"version\":     \"$VERSION\","
    echo "  \"built_at\":    \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
    echo "  \"gpu_arch\":    \"gfx1151\","
    echo "  \"host_kernel\": \"$(uname -r)\","
    echo "  \"rocm_version\": \"$(hipconfig --version 2>/dev/null || echo unknown)\","
    echo "  \"commits\": {"
    echo "    \"rocm-cpp\":   \"$(git -C "$ROCMCPP"   rev-parse HEAD 2>/dev/null || echo unknown)\","
    echo "    \"agent-cpp\":  \"$(git -C "$AGENTCPP"  rev-parse HEAD 2>/dev/null || echo unknown)\","
    echo "    \"halo-1bit\":  \"$(git -C "$HALO1BIT"  rev-parse HEAD 2>/dev/null || echo unknown)\""
    echo "  },"
    echo "  \"assets\": ["
    first=1
    for f in "$DIST"/*.tar.zst; do
        [[ $first -eq 1 ]] || echo ","
        first=0
        name=$(basename "$f")
        bytes=$(stat -c%s "$f")
        sha=$(sha256sum "$f" | cut -d' ' -f1)
        printf '    {"name": "%s", "bytes": %s, "sha256": "%s"}' "$name" "$bytes" "$sha"
    done
    echo
    echo "  ]"
    echo "}"
} > "$DIST/MANIFEST.json"
ok "MANIFEST.json written"

# ── Summary ─────────────────────────────────────────────────
echo
log "release artifacts at $DIST:"
ls -lh "$DIST" | tail -n +2
echo
log "next: ./release/upload-release.sh  (pushes to GH Releases)"
