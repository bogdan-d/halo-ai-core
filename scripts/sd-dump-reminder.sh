#!/bin/bash
# sd-dump-reminder.sh — Remind to dump TASCAM SD cards
# Run via cron or systemd timer
# stamped by the architect

DAYS_BETWEEN="${SD_DUMP_INTERVAL_DAYS:-7}"
DUMP_DIR="${SD_DUMP_DIR:-/shared/ryzen/audio-dumps}"
LOG="$DUMP_DIR/dump.log"

# Check last dump date
if [ -f "$LOG" ]; then
    LAST=$(tail -1 "$LOG" | cut -d'|' -f1 | xargs)
    LAST_DATE=$(echo "$LAST" | cut -d'-' -f1)
    LAST_EPOCH=$(date -d "$LAST_DATE" +%s 2>/dev/null || echo 0)
    NOW_EPOCH=$(date +%s)
    DAYS_AGO=$(( (NOW_EPOCH - LAST_EPOCH) / 86400 ))

    if [ "$DAYS_AGO" -ge "$DAYS_BETWEEN" ]; then
        MSG="SD card dump overdue. Last dump: $DAYS_AGO days ago ($LAST_DATE). Plug in cards and run: sd-dump.sh"
    else
        exit 0
    fi
else
    MSG="No SD card dumps recorded yet. Plug in cards and run: sd-dump.sh"
fi

# Desktop notification
notify-send "TASCAM SD Dump" "$MSG" --icon=media-removable 2>/dev/null || true

# Discord notification via Echo
if [ -n "${DISCORD_WEBHOOK:-}" ]; then
    curl -s -X POST "$DISCORD_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d "{\"content\":\"**SD Card Dump Reminder**\n$MSG\"}" > /dev/null 2>&1
fi

echo "$MSG"
