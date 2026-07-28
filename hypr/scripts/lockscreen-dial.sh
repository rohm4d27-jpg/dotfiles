#!/bin/bash
# lockscreen-dial.sh TYPE OFFSET SPACING [WEIGHT]
# TYPE:    H (hours) | M (minutes) | S (seconds)
# OFFSET:  -1 (prev) | 0 (current) | 1 (next)
# SPACING: Pango letter_spacing in 1/1024-pt units (e.g. 5000)
# WEIGHT:  Pango weight string (semibold | bold | black)

TYPE="${1:-H}"
OFFSET="${2:-0}"
SPACING="${3:-5000}"
WEIGHT="${4:-bold}"

case "$TYPE" in
  H) VAL=$(date +%H | awk -v o="$OFFSET" '{printf "%02d", (($1 + o) % 24 + 24) % 24}') ;;
  M) VAL=$(date +%M | awk -v o="$OFFSET" '{printf "%02d", (($1 + o) % 60 + 60) % 60}') ;;
  S) VAL=$(date +%S | awk -v o="$OFFSET" '{printf "%02d", (($1 + o) % 60 + 60) % 60}') ;;
  *) VAL="00" ;;
esac

printf '<span weight="%s" letter_spacing="%s">%s</span>' "$WEIGHT" "$SPACING" "$VAL"
