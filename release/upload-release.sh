#!/usr/bin/env bash
# halo-ai-core release/upload-release.sh — push built artifacts to GH Releases.
#
# Assumes:
#   - ./release/build-release.sh has populated release/dist/
#   - gh CLI is authenticated (gh auth status)
#   - Current HEAD is tagged (or --draft is fine without a tag)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$ROOT/release/dist"
TAG="${TAG:-$(git -C "$ROOT" describe --tags --abbrev=0 2>/dev/null || echo "")}"
DRAFT=0
PRERELEASE=0
NOTES_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --tag)       TAG="$2"; shift 2 ;;
        --draft)     DRAFT=1; shift ;;
        --prerelease) PRERELEASE=1; shift ;;
        --notes)     NOTES_FILE="$2"; shift 2 ;;
        --help|-h)
            cat <<EOF
Usage: ./upload-release.sh [--tag vX.Y.Z] [--draft] [--prerelease] [--notes FILE]

Pushes the tarballs from release/dist/ to github.com/stampby/halo-ai-core
as a new release tagged TAG.
EOF
            exit 0 ;;
        *) echo "unknown arg: $1"; exit 1 ;;
    esac
done

[[ -d "$DIST" ]]                        || { echo "no release/dist — run build-release.sh first"; exit 1; }
[[ -n "$TAG" ]]                         || { echo "no tag — pass --tag vX.Y.Z or git tag HEAD first"; exit 1; }
compgen -G "$DIST/*.tar.zst" >/dev/null || { echo "no tarballs in $DIST"; exit 1; }
command -v gh >/dev/null                || { echo "gh CLI required"; exit 1; }
gh auth status >/dev/null 2>&1          || { echo "gh not authenticated — run 'gh auth login'"; exit 1; }

ARGS=(--title "halo-ai-core $TAG")
[[ $DRAFT -eq 1 ]]      && ARGS+=(--draft)
[[ $PRERELEASE -eq 1 ]] && ARGS+=(--prerelease)
if [[ -n "$NOTES_FILE" && -f "$NOTES_FILE" ]]; then
    ARGS+=(--notes-file "$NOTES_FILE")
else
    ARGS+=(--generate-notes)
fi

echo "→ gh release create $TAG ${ARGS[*]} <assets...>"
gh release create "$TAG" "${ARGS[@]}" "$DIST"/*.tar.zst "$DIST/SHA256SUMS" \
    $([[ -f "$DIST/SHA256SUMS.asc" ]] && echo "$DIST/SHA256SUMS.asc") \
    "$DIST/MANIFEST.json"
echo "✓ release published: https://github.com/stampby/halo-ai-core/releases/tag/$TAG"
