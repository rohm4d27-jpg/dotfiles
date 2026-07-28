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
link swaync

# Wallpaper: stored in wallpaper/ (separate from configs), linked into hypr/
# To change wallpaper: edit wallpaper/hyprpaper.conf and update the image path
ln -sfn "$DOTFILES_DIR/wallpaper/hyprpaper.conf" "$HOME/.config/hypr/hyprpaper.conf"
echo "  linked wallpaper/hyprpaper.conf"

# SDDM login theme — requires sudo (system path)
echo "Installing SDDM login theme (requires sudo)..."
sudo cp "$DOTFILES_DIR/sddm/Main.qml" /usr/share/sddm/themes/omarchy/Main.qml
echo "  installed sddm/Main.qml → /usr/share/sddm/themes/omarchy/Main.qml"

echo "Done. Run 'omarchy restart waybar' to apply Waybar changes."
