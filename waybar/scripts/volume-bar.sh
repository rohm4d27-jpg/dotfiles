#!/bin/bash

print_pct() {
  local info vol muted
  info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
  vol=$(awk '{printf "%d", $2*100}' <<<"$info")
  ((vol < 0)) && vol=0
  ((vol > 100)) && vol=100
  muted=""
  [[ "$info" == *MUTED* ]] && muted=1

  if [[ -n "$muted" ]]; then
    printf '<span foreground="#ffffff73">%s%%</span>\n' "$vol"
  else
    printf '<span foreground="#ffffff99">%s%%</span>\n' "$vol"
  fi
}

print_pct
while true; do
  pactl subscribe 2>/dev/null | while read -r _; do
    print_pct
  done
  sleep 0.5
done
