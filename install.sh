#!/usr/bin/env bash
# Dotfiles installer — links configs to ~/.config/
# Usage: bash install.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

link() {
    local src="$DOTFILES_DIR/$1"
    local dst="$CONFIG_DIR/$1"

    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "  backing up $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    echo "  linked $1"
}

echo "Installing dotfiles..."
link hypr
link waybar
link mako
link walker
link ghostty
link kitty
link foot
link alacritty
echo "Done. Restart Hyprland to apply all changes."
