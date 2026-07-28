#!/bin/bash
# Toggle fullscreen for the active window.
# Also slides waybar up (hides) when going fullscreen,
# and slides it back down when exiting fullscreen.

FLAG="/tmp/waybar-fullscreen-hidden"

FULLSCREEN=$(hyprctl -j activewindow 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('fullscreen', 0))
except:
    print(0)
")

if [ "$FULLSCREEN" = "0" ]; then
    hyprctl dispatch fullscreen 0
    if [ ! -f "$FLAG" ]; then
        touch "$FLAG"
        pkill -SIGUSR1 waybar 2>/dev/null || true
    fi
else
    hyprctl dispatch fullscreen 0
    if [ -f "$FLAG" ]; then
        rm -f "$FLAG"
        pkill -SIGUSR1 waybar 2>/dev/null || true
    fi
fi
