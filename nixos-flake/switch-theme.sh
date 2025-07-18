#!/usr/bin/env bash

THEMES_DIR="$HOME/.config/themes"
CONFIG_DIR="$HOME/.config"

function apply_theme() {
  local theme=$1
  
  # Verify theme exists
  if [[ ! -d "$THEMES_DIR/$theme" ]]; then
    notify-send "Theme Error" "Theme $theme not found!"
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

  # Hyprland
  if [[ -f "$THEMES_DIR/$theme/hyprland.conf" ]]; then
    mkdir -p "$CONFIG_DIR/hypr"
    cp -v "$THEMES_DIR/$theme/hyprland.conf" "$CONFIG_DIR/hypr/hyprland.conf"
  fi

  # Reload systems
  pkill -USR1 kitty
  pkill waybar && waybar >/dev/null 2>&1 &
  hyprctl reload

  notify-send "Theme Changed" "Applied $theme theme successfully"
}

# Theme selection
THEME=$(ls "$THEMES_DIR" | rofi -dmenu -p "Select theme")

[[ -n "$THEME" ]] && apply_theme "$THEME" || exit 0