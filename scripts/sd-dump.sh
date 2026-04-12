#!/bin/bash
# sd-dump.sh — Auto-dump TASCAM DR-10L SD cards
# Plug cards in, run this, everything gets copied and organized
# stamped by the architect
set -euo pipefail

DUMP_DIR="${SD_DUMP_DIR:-/shared/ryzen/audio-dumps}"
LOG="$DUMP_DIR/dump.log"
NOTIFY="${SD_NOTIFY:-true}"

mkdir -p "$DUMP_DIR"

echo "╔═══════════════════════════════════╗"
echo "║  SD Card Dump Station             ║"
echo "║  TASCAM DR-10L auto-dump          ║"
echo "╚═══════════════════════════════════╝"
echo ""

# Find all mounted removable media
CARDS=()
for dev in /media/$USER/* /run/media/$USER/* /mnt/sd*; do
    [ -d "$dev" ] || continue
    # Check for TASCAM file structure
    if [ -d "$dev/SOUND" ] || ls "$dev"/*.wav 2>/dev/null | head -1 > /dev/null 2>&1; then
        CARDS+=("$dev")
    fi
done

if [ ${#CARDS[@]} -eq 0 ]; then
    echo "No TASCAM SD cards found."
    echo "Insert cards and mount them, or check /run/media/$USER/"
    echo ""
    echo "To auto-mount: udisksctl mount -b /dev/sdX1"
    exit 0
fi

echo "Found ${#CARDS[@]} TASCAM card(s):"
for card in "${CARDS[@]}"; do
    count=$(find "$card" -name "*.wav" -o -name "*.WAV" 2>/dev/null | wc -l)
    size=$(du -sh "$card" 2>/dev/null | cut -f1)
    echo "  $card — $count files, $size"
done
echo ""

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TOTAL_FILES=0
TOTAL_BYTES=0

for i in "${!CARDS[@]}"; do
    card="${CARDS[$i]}"
    card_num=$((i + 1))
    dest="$DUMP_DIR/$TIMESTAMP/card-$card_num"
    mkdir -p "$dest"

    echo "Dumping card $card_num: $card → $dest"

    # Copy all audio files preserving timestamps
    find "$card" -type f \( -name "*.wav" -o -name "*.WAV" -o -name "*.mp3" -o -name "*.MP3" \) -exec cp -v --preserve=timestamps {} "$dest/" \;

    files=$(find "$dest" -type f | wc -l)
    bytes=$(du -sb "$dest" | cut -f1)
    TOTAL_FILES=$((TOTAL_FILES + files))
    TOTAL_BYTES=$((TOTAL_BYTES + bytes))

    echo "  Card $card_num: $files files copied"
    echo ""
done

# Summary
SIZE_MB=$((TOTAL_BYTES / 1048576))
echo "═══════════════════════════════════"
echo "  Dump complete: $TOTAL_FILES files, ${SIZE_MB}MB"
echo "  Location: $DUMP_DIR/$TIMESTAMP/"
echo "═══════════════════════════════════"

# Log
echo "$TIMESTAMP | ${#CARDS[@]} cards | $TOTAL_FILES files | ${SIZE_MB}MB" >> "$LOG"

# Verify checksums
echo ""
echo "Verifying copies..."
ERRORS=0
for i in "${!CARDS[@]}"; do
    card="${CARDS[$i]}"
    card_num=$((i + 1))
    dest="$DUMP_DIR/$TIMESTAMP/card-$card_num"

    for src_file in $(find "$card" -type f \( -name "*.wav" -o -name "*.WAV" \) 2>/dev/null); do
        fname=$(basename "$src_file")
        dst_file="$dest/$fname"
        if [ -f "$dst_file" ]; then
            src_sum=$(md5sum "$src_file" | cut -d' ' -f1)
            dst_sum=$(md5sum "$dst_file" | cut -d' ' -f1)
            if [ "$src_sum" != "$dst_sum" ]; then
                echo "  MISMATCH: $fname on card $card_num"
                ERRORS=$((ERRORS + 1))
            fi
        else
            echo "  MISSING: $fname on card $card_num"
            ERRORS=$((ERRORS + 1))
        fi
    done
done

if [ "$ERRORS" -eq 0 ]; then
    echo "  All files verified. Safe to format cards."
else
    echo "  $ERRORS errors found. DO NOT format cards."
fi
