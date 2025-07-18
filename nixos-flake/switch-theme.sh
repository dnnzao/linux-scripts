#!/usr/bin/env bash

THEMES_DIR="$HOME/.config/themes"
KITTY_CONFIG_DIR="$HOME/.config/kitty"
WAYBAR_CONFIG_DIR="$HOME/.config/waybar"
WOFI_CONFIG_DIR="$HOME/.config/wofi"
HYPRLAND_CONFIG_DIR="$HOME/.config/hypr"

function apply_theme() {
  local theme=$1
  echo "Applying theme: $theme"

  cp $THEMES_DIR/$theme/kitty.conf $KITTY_CONFIG_DIR/kitty.conf
  cp $THEMES_DIR/$theme/waybar/* $WAYBAR_CONFIG_DIR/
  cp $THEMES_DIR/$theme/wofi/* $WOFI_CONFIG_DIR/
  cp $THEMES_DIR/$theme/hyprland.conf $HYPRLAND_CONFIG_DIR/hyprland.conf

  # Reload kitty
  pkill -USR1 kitty

  # Reload waybar
  pkill waybar && waybar &

  # Reload hyprland
  hyprctl reload

  echo "Theme $theme applied!"
}

THEME=$(wofi --show dmenu --prompt "Select theme:" -d <<< "catppuccin
tokyonight
nord")

if [[ -n "$THEME" ]]; then
  apply_theme "$THEME"
else
  echo "No theme selected, aborting."
fi
