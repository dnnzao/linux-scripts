#!/usr/bin/env bash
set -euo pipefail

THEMES_DIR="$HOME/.config/themes"
CONFIG_DIR="$HOME/.config"

notify() {
  notify-send -a "Theme Switcher" "$1" "$2"
}

apply_theme() {
  local theme="$1"
  
  # Validate theme exists
  if [[ ! -d "$THEMES_DIR/$theme" ]]; then
    notify "Error" "Theme $theme not found!"
    exit 1
  fi

  # Kitty
  mkdir -p "$CONFIG_DIR/kitty"
  cp -v "$THEMES_DIR/$theme/kitty.conf" "$CONFIG_DIR/kitty/"

  # Waybar
  if [[ -d "$THEMES_DIR/$theme/waybar" ]]; then
    mkdir -p "$CONFIG_DIR/waybar"
    cp -v "$THEMES_DIR/$theme/waybar/"* "$CONFIG_DIR/waybar/"
  fi

  # Wofi/Rofi
  if [[ -d "$THEMES_DIR/$theme/wofi" ]]; then
    mkdir -p "$CONFIG_DIR/wofi"
    cp -v "$THEMES_DIR/$theme/wofi/"* "$CONFIG_DIR/wofi/"
  elif [[ -d "$THEMES_DIR/$theme/rofi" ]]; then
    mkdir -p "$CONFIG_DIR/rofi"
    cp -v "$THEMES_DIR/$theme/rofi/"* "$CONFIG_DIR/rofi/"
  fi

  # Hyprland
  if [[ -f "$THEMES_DIR/$theme/hyprland.conf" ]]; then
    mkdir -p "$CONFIG_DIR/hypr"
    cp -v "$THEMES_DIR/$theme/hyprland.conf" "$CONFIG_DIR/hypr/hyprland.conf"
  fi

  # Reload components
  pkill -USR1 kitty || true
  pkill waybar && waybar >/dev/null 2>&1 &
  hyprctl reload

  # GTK Theme (optional)
  if which gsettings >/dev/null; then
    case "$theme" in
      catppuccin) gsettings set org.gnome.desktop.interface gtk-theme "Catppuccin-Mocha" ;;
      tokyonight) gsettings set org.gnome.desktop.interface gtk-theme "TokyoNight-Storm" ;;
      nord) gsettings set org.gnome.desktop.interface gtk-theme "Nordic" ;;
    esac
  fi

  notify "Theme Changed" "Applied $theme theme successfully"
}

# Theme selection UI
if which wofi >/dev/null; then
  THEME=$(wofi --show dmenu --prompt "Select Theme" <<< "catppuccin
tokyonight
nord")
elif which rofi >/dev/null; then
  THEME=$(echo -e "catppuccin\ntokyonight\nnord" | rofi -dmenu -p "Select Theme")
else
  echo "ERROR: Neither wofi nor rofi found!" >&2
  exit 1
fi

[[ -n "$THEME" ]] && apply_theme "$THEME"