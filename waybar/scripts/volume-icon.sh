#!/bin/bash
# Renders a single glass-pill volume slider (speaker glyph + live fill bar)
# as a PNG that waybar's image#volume module displays.

OUT="$HOME/.cache/waybar-volume-icon.png"
W=70
H=20

TRACK_COLOR="#ffffff2e"
FILL_COLOR="#6fb3e0"
FILL_MUTED="#ffffff59"
ICON_COLOR="#ffffffd0"
ICON_MUTED="#ffffff59"

info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
vol=$(awk '{printf "%d", $2*100}' <<<"$info")
((vol < 0)) && vol=0
((vol > 100)) && vol=100
muted=0
[[ "$info" == *MUTED* ]] && muted=1

# ── Bar geometry ──
bar_x1=18
bar_x2=66
bar_y1=8
bar_y2=12
bar_r=2
bar_w=$((bar_x2 - bar_x1))

fill_w=$((bar_w * vol / 100))
((fill_w < bar_r * 2 && fill_w > 0)) && fill_w=$((bar_r * 2))
fill_x2=$((bar_x1 + fill_w))

fill_color="$FILL_COLOR"
icon_color="$ICON_COLOR"
((muted)) && fill_color="$FILL_MUTED" && icon_color="$ICON_MUTED"

draw=(
  # speaker body + cone
  -fill "$icon_color" -draw "polygon 2,7 6,7 6,13 2,13"
  -fill "$icon_color" -draw "polygon 6,7 11,3 11,17 6,13"
  # track
  -fill "$TRACK_COLOR" -draw "roundrectangle $bar_x1,$bar_y1 $bar_x2,$bar_y2 $bar_r,$bar_r"
)

if ((!muted)); then
  draw+=(-stroke "$icon_color" -strokewidth 1.4 -fill none -draw "path 'M 13,7 A 5,5 0 0 1 13,13'")
else
  draw+=(-stroke "$icon_color" -strokewidth 1.4 -draw "line 12,6 17,14" -draw "line 12,14 17,6")
fi

if ((fill_w > 0)); then
  draw+=(-fill "$fill_color" -draw "roundrectangle $bar_x1,$bar_y1 $fill_x2,$bar_y2 $bar_r,$bar_r")
fi

magick -size "${W}x${H}" xc:none "${draw[@]}" "$OUT"

echo "$OUT"
