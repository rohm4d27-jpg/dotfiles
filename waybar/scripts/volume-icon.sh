#!/bin/bash

OUT="$HOME/.cache/waybar-volume-icon.png"
SIZE=16
CX=8
CY=7.5
R=5.8
STROKE=2.3
COLOR_NORMAL="#ffffff9e"
COLOR_MUTED="#ffffff59"

info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
vol=$(awk '{printf "%d", $2*100}' <<<"$info")
((vol < 0)) && vol=0
((vol > 100)) && vol=100

if [[ "$info" == *MUTED* ]]; then
  angle=12
  color="$COLOR_MUTED"
else
  angle=$(( (vol * 360 + 50) / 100 ))
  ((angle < 12)) && angle=12
  color="$COLOR_NORMAL"
fi

read -r top_x top_y ex ey large full <<<"$(awk -v a="$angle" -v cx="$CX" -v cy="$CY" -v r="$R" 'BEGIN {
  pi = atan2(0, -1); rad = a * pi / 180
  top_x = cx; top_y = cy - r
  ex = cx + r * sin(rad); ey = cy - r * cos(rad)
  large = (a > 180) ? 1 : 0
  full = (a >= 358) ? 1 : 0
  printf "%.3f %.3f %.3f %.3f %d %d", top_x, top_y, ex, ey, large, full
}')"

if ((full)); then
  magick -size "${SIZE}x${SIZE}" xc:none -stroke "$color" -strokewidth "$STROKE" -fill none \
    -draw "stroke-linecap round circle $CX,$CY $top_x,$top_y" "$OUT"
else
  magick -size "${SIZE}x${SIZE}" xc:none -stroke "$color" -strokewidth "$STROKE" -fill none \
    -draw "stroke-linecap round path 'M $top_x,$top_y A $R,$R 0 $large,1 $ex,$ey'" "$OUT"
fi

echo "$OUT"
