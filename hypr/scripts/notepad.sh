#!/bin/bash
# Quick notepad — floating glass popup centered on screen.
# Type your note, save with Ctrl+O, exit with Ctrl+X. Content persists between opens.

NOTE_FILE="$HOME/.local/share/notepad/notes.txt"
mkdir -p "$(dirname "$NOTE_FILE")"
touch "$NOTE_FILE"

# org.omarchy.terminal is already tagged floating-window (float + center + 875x600)
# by omarchy's default window rules, so it gets the same glass look as other popups.
exec setsid uwsm-app -- xdg-terminal-exec --app-id=org.omarchy.terminal --title=Notepad -e nano "$NOTE_FILE"
