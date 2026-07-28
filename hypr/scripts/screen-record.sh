#!/usr/bin/env bash

OUT="$HOME/Videos/Recordings"
mkdir -p "$OUT"

if pgrep -x gpu-screen-recorder >/dev/null; then
    pkill -INT gpu-screen-recorder
    notify-send "Recording Saved"
    exit 0
fi

CHOICE=$(
printf "Entire Screen\nCurrent Window\nSelected Area" |
walker --dmenu
)

FILENAME="$OUT/$(date '+%Y-%m-%d_%H-%M-%S').mp4"

case "$CHOICE" in

"Entire Screen")
gpu-screen-recorder \
-w screen \
-f 60 \
-c mp4 \
-o "$FILENAME"
;;

"Current Window")
gpu-screen-recorder \
-w focused \
-f 60 \
-c mp4 \
-o "$FILENAME"
;;

"Selected Area")
AREA=$(slurp)

gpu-screen-recorder \
-w region \
-region "$AREA" \
-f 60 \
-c mp4 \
-o "$FILENAME"
;;

esac
