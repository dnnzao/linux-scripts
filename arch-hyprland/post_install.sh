#!/bin/bash
#===============================================================================
# Arch Linux Post Installation - Hyprland Setup
# Author: Dênio Barbosa Júnior
# Description: Installs Hyprland, applications, and configurations
#===============================================================================

set -e

# Colors and logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
section() { echo -e "\n${PURPLE}[SECTION]${NC} $1\n"; }

# Create log file
exec > >(tee -a ~/post_install.log)
exec 2>&1

section "Starting Hyprland setup for Dênio Barbosa Júnior..."
log "Timestamp: $(date)"

# Wait for network
log "Waiting for network connection..."
while ! ping -c 1 google.com &> /dev/null; do
    sleep 2
done
log "Network connected"

# Update system
section "Updating system..."
sudo pacman -Syu --noconfirm

# Install paru AUR helper
section "Installing paru AUR helper..."
if ! command -v paru &> /dev/null; then
    cd /tmp
    sudo pacman -S --needed --noconfirm git
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ~
    log "Paru installed successfully"
else
    log "Paru already installed"
fi

# Install balanced packages (functionality + rice-ability)
section "Installing essential packages..."
sudo pacman -S --needed --noconfirm \
    bluez bluez-utils \
    xdg-desktop-portal-hyprland \
    polkit-gnome \
    qt5-wayland qt6-wayland \
    grim slurp swappy \
    wl-clipboard \
    brightnessctl playerctl \
    thunar thunar-archive-plugin \
    firefox chromium \
    vlc mpv \
    neofetch htop btop \
    unzip p7zip ark \
    noto-fonts noto-fonts-emoji \
    ttf-jetbrains-mono-nerd ttf-fira-code \
    papirus-icon-theme arc-gtk-theme \
    lxappearance qt5ct \
    starship \
    pavucontrol

# Install development tools for Dênio Barbosa Júnior
section "Installing development tools..."
sudo pacman -S --needed --noconfirm \
    go rust python python-pip \
    postgresql postgresql-contrib \
    docker docker-compose \
    neovim vim \
    code

# Install balanced Hyprland ecosystem (rice-able + functional)
section "Installing Hyprland ecosystem..."
paru -S --needed --noconfirm \
    hyprland-git \
    hyprpaper-git \
    hyprlock-git \
    hypridle-git \
    waybar-hyprland-git \
    eww-wayland \
    rofi-wayland wofi \
    swww \
    dunst mako \
    wlogout \
    kitty alacritty wezterm \
    cava \
    fastfetch \
    btop-git

# Install gaming tools
section "Installing gaming tools..."
sudo pacman -S --needed --noconfirm \
    steam \
    wine wine-gecko wine-mono \
    lutris \
    gamemode lib32-gamemode

paru -S --needed --noconfirm \
    wine-ge-custom \
    heroic-games-launcher-bin

# Install GUI applications for Dênio Barbosa Júnior
section "Installing GUI applications..."
paru -S --needed --noconfirm \
    discord \
    notion-app-enhanced \
    visual-studio-code-bin \
    cursor-bin \
    brave-bin \
    google-chrome \
    sublime-text-4 \
    spotify \
    obs-studio

# Enable services
section "Enabling services..."
sudo systemctl enable docker
sudo systemctl enable postgresql
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# Add user to groups
sudo usermod -aG docker,input,video $USER

# Install display manager
section "Installing display manager..."
paru -S --needed --noconfirm greetd-tuigreet
sudo systemctl enable greetd

# Create enhanced Hyprland config with theming support
section "Creating Hyprland configuration..."
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/hyprland.conf << 'HYPR_EOF'
# Monitor configuration
monitor=,preferred,auto,1

# Environment variables for theming
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt5ct

# Autostart
exec-once = waybar
exec-once = dunst
exec-once = swww init
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

# Input configuration for US International keyboard
input {
    kb_layout = us
    kb_variant = intl
    kb_model =
    kb_options =
    kb_rules =
    follow_mouse = 1
    touchpad {
        natural_scroll = true
        tap-to-click = true
        disable_while_typing = true
    }
    sensitivity = 0
    accel_profile = flat
}

# General settings (enhanced for ricing)
general {
    gaps_in = 8
    gaps_out = 15
    border_size = 3
    col.active_border = rgba(7aa2f7ff) rgba(bb9af7ff) 45deg
    col.inactive_border = rgba(414868aa)
    layout = dwindle
    allow_tearing = false
    resize_on_border = true
}

# Enhanced decoration for visual appeal
decoration {
    rounding = 12
    blur {
        enabled = true
        size = 6
        passes = 3
        new_optimizations = true
        xray = true
        ignore_opacity = true
    }
    drop_shadow = true
    shadow_range = 20
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
    shadow_offset = 0 2
    
    active_opacity = 0.95
    inactive_opacity = 0.85
    fullscreen_opacity = 1.0
}

# Smooth animations
animations {
    enabled = true
    bezier = wind, 0.05, 0.9, 0.1, 1.05
    bezier = winIn, 0.1, 1.1, 0.1, 1.1
    bezier = winOut, 0.3, -0.3, 0, 1
    bezier = liner, 1, 1, 1, 1
    
    animation = windows, 1, 6, wind, slide
    animation = windowsIn, 1, 6, winIn, slide
    animation = windowsOut, 1, 5, winOut, slide
    animation = windowsMove, 1, 5, wind, slide
    animation = border, 1, 1, liner
    animation = borderangle, 1, 30, liner, loop
    animation = fade, 1, 10, default
    animation = workspaces, 1, 5, wind
}

# Layout
dwindle {
    pseudotile = true
    preserve_split = true
    smart_split = true
    smart_resizing = true
}

# Window rules for better theming
windowrule = opacity 0.9,^(kitty)$
windowrule = opacity 0.9,^(alacritty)$
windowrule = opacity 0.95,^(code)$
windowrule = opacity 0.95,^(firefox)$
windowrule = float,^(pavucontrol)$
windowrule = float,^(lxappearance)$
windowrule = float,^(qt5ct)$

# Key bindings
$mainMod = SUPER

# Application shortcuts
bind = $mainMod, Return, exec, kitty
bind = $mainMod SHIFT, Return, exec, alacritty
bind = $mainMod ALT, Return, exec, wezterm
bind = $mainMod, C, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, rofi -show drun
bind = $mainMod SHIFT, R, exec, wofi --show drun
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,
bind = $mainMod, F, fullscreen,
bind = $mainMod, L, exec, hyprlock

# Move focus with vim keys
bind = $mainMod, h, movefocus, l
bind = $mainMod, l, movefocus, r
bind = $mainMod, k, movefocus, u
bind = $mainMod, j, movefocus, d

# Move focus with arrows
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Move windows
bind = $mainMod SHIFT, h, movewindow, l
bind = $mainMod SHIFT, l, movewindow, r
bind = $mainMod SHIFT, k, movewindow, u
bind = $mainMod SHIFT, j, movewindow, d

# Resize windows
bind = $mainMod CTRL, h, resizeactive, -20 0
bind = $mainMod CTRL, l, resizeactive, 20 0
bind = $mainMod CTRL, k, resizeactive, 0 -20
bind = $mainMod CTRL, j, resizeactive, 0 20

# Switch workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move windows to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Volume and brightness
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86MonBrightnessUp, exec, brightnessctl s 10%+
bind = , XF86MonBrightnessDown, exec, brightnessctl s 10%-

# Media keys
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous

# Screenshots
bind = , Print, exec, grim -g "$(slurp)" - | swappy -f -
bind = $mainMod, Print, exec, grim - | swappy -f -
bind = $mainMod SHIFT, S, exec, grim -g "$(slurp)" - | swappy -f -

# Special workspace (scratchpad)
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic
HYPR_EOF

log "Enhanced Hyprland configuration created"

# Create enhanced waybar config
section "Creating Waybar configuration..."
mkdir -p ~/.config/waybar
cat > ~/.config/waybar/config << 'WAYBAR_EOF'
{
    "layer": "top",
    "position": "top",
    "height": 35,
    "spacing": 4,
    "margin-top": 8,
    "margin-left": 12,
    "margin-right": 12,
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "cpu", "memory", "battery", "tray"],
    
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "format": "{icon}",
        "format-icons": {
            "1": "󰲠",
            "2": "󰲢",
            "3": "󰲤",
            "4": "󰲦",
            "5": "󰲨",
            "6": "󰲪",
            "7": "󰲬",
            "8": "󰲮",
            "9": "󰲰",
            "10": "󰿬",
            "urgent": "",
            "focused": "",
            "default": ""
        }
    },
    
    "hyprland/window": {
        "format": "{}",
        "max-length": 50,
        "separate-outputs": true
    },
    
    "clock": {
        "timezone": "America/Sao_Paulo",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format": "{:%H:%M}",
        "format-alt": "{:%Y-%m-%d}"
    },
    
    "cpu": {
        "format": "{usage}% ",
        "tooltip": false,
        "interval": 2
    },
    
    "memory": {
        "format": "{}% "
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-charging": "{capacity}% ",
        "format-plugged": "{capacity}% ",
        "format-alt": "{time} {icon}",
        "format-icons": ["", "", "", "", ""]
    },
    
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "{ipaddr}/{cidr} ",
        "tooltip-format": "{ifname} via {gwaddr} ",
        "format-linked": "{ifname} (No IP) ",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}"
    },
    
    "pulseaudio": {
        "format": "{volume}% {icon} {format_source}",
        "format-bluetooth": "{volume}% {icon} {format_source}",
        "format-bluetooth-muted": " {icon} {format_source}",
        "format-muted": " {format_source}",
        "format-source": "{volume}% ",
        "format-source-muted": "",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    },
    
    "tray": {
        "spacing": 10
    }
}
WAYBAR_EOF

# Create waybar CSS for theming
cat > ~/.config/waybar/style.css << 'WAYBAR_CSS'
* {
    font-family: JetBrainsMono Nerd Font;
    font-size: 14px;
    font-weight: bold;
}

window#waybar {
    background-color: rgba(26, 27, 38, 0.85);
    border-radius: 12px;
    color: #c0caf5;
    transition-property: background-color;
    transition-duration: .5s;
}

button {
    box-shadow: inset 0 -3px transparent;
    border: none;
    border-radius: 8px;
}

#workspaces button {
    padding: 5px 8px;
    background-color: transparent;
    color: #7aa2f7;
}

#workspaces button:hover {
    background: rgba(116, 199, 236, 0.2);
}

#workspaces button.active {
    background-color: #7aa2f7;
    color: #1a1b26;
}

#workspaces button.urgent {
    background-color: #f7768e;
    color: #1a1b26;
}

#clock,
#battery,
#cpu,
#memory,
#network,
#pulseaudio,
#tray,
#window {
    padding: 4px 8px;
    margin: 0 4px;
    background-color: rgba(122, 162, 247, 0.1);
    border-radius: 8px;
}

#battery.charging, #battery.plugged {
    color: #9ece6a;
}

#battery.critical:not(.charging) {
    background-color: #f7768e;
    color: #1a1b26;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

@keyframes blink {
    to {
        background-color: #ffffff;
        color: #000000;
    }
}
WAYBAR_CSS

log "Waybar configuration created"

# Configure terminals with custom keybindings
section "Configuring terminal keybindings..."

# Kitty config - Ctrl+C/V for copy/paste, Ctrl+Shift+C for interrupt
mkdir -p ~/.config/kitty
cat > ~/.config/kitty/kitty.conf << 'KITTY_EOF'
# Copy/paste with Ctrl+C/V
map ctrl+c copy_to_clipboard
map ctrl+v paste_from_clipboard

# Process interrupt with Ctrl+Shift+C
map ctrl+shift+c send_text all \x03

# Font settings
font_family JetBrainsMono Nerd Font
font_size 12.0

# Theme
background_opacity 0.9
KITTY_EOF

# Alacritty config - Ctrl+C/V for copy/paste, Ctrl+Shift+C for interrupt
mkdir -p ~/.config/alacritty
cat > ~/.config/alacritty/alacritty.yml << 'ALACRITTY_EOF'
font:
  normal:
    family: JetBrainsMono Nerd Font
  size: 12.0

window:
  opacity: 0.9

key_bindings:
  # Copy/paste with Ctrl+C/V
  - { key: C, mods: Control, action: Copy }
  - { key: V, mods: Control, action: Paste }
  
  # Process interrupt with Ctrl+Shift+C
  - { key: C, mods: Control|Shift, chars: "\x03" }
ALACRITTY_EOF

# Wezterm config - Ctrl+C/V for copy/paste, Ctrl+Shift+C for interrupt
mkdir -p ~/.config/wezterm
cat > ~/.config/wezterm/wezterm.lua << 'WEZTERM_EOF'
local wezterm = require 'wezterm'
local config = {}

-- Font
config.font = wezterm.font('JetBrainsMono Nerd Font')
config.font_size = 12.0

-- Appearance
config.window_background_opacity = 0.9

-- Key bindings
config.keys = {
  -- Copy/paste with Ctrl+C/V
  { key = 'c', mods = 'CTRL', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
  
  -- Process interrupt with Ctrl+Shift+C
  { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.SendKey { key = 'c', mods = 'CTRL' } },
}

return config
WEZTERM_EOF

log "Terminal configurations created with custom keybindings"

# Set up shell environment
section "Setting up shell environment..."
if [[ ! -f ~/.zshrc ]]; then
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
    echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.zshrc
    echo 'alias ll="ls -la"' >> ~/.zshrc
    echo 'alias la="ls -A"' >> ~/.zshrc
    echo 'alias l="ls -CF"' >> ~/.zshrc
fi

# Create rofi config
section "Creating rofi configuration..."
mkdir -p ~/.config/rofi
cat > ~/.config/rofi/config.rasi << 'ROFI_EOF'
configuration {
    modi: "drun,run,window";
    width: 50;
    lines: 15;
    columns: 1;
    font: "JetBrainsMono Nerd Font 12";
    show-icons: true;
    terminal: "kitty";
    drun-display-format: "{icon} {name}";
    location: 0;
    disable-history: false;
    hide-scrollbar: true;
    display-drun: "   Apps ";
    display-run: "   Run ";
    display-window: " 﩯  Window";
    display-Network: " 󰤨  Network";
    sidebar-mode: true;
}

@theme "~/.config/rofi/launcher.rasi"
ROFI_EOF

# Create rofi theme
cat > ~/.config/rofi/launcher.rasi << 'ROFI_THEME'
* {
    background-color: rgba(26, 27, 38, 0.95);
    border-color: #7aa2f7;
    text-color: #c0caf5;
    spacing: 0;
    width: 512px;
}

inputbar {
    border: 0 0 1px 0;
    children: [prompt,entry];
}

prompt {
    padding: 16px;
    border: 0 1px 0 0;
}

textbox {
    background-color: #1a1b26;
    border: 0 0 1px 0;
    border-color: #7aa2f7;
    padding: 8px 16px;
}

entry {
    padding: 16px;
}

listview {
    cycle: false;
    margin: 0 0 -1px 0;
    scrollbar: false;
}

element {
    border: 0 0 1px 0;
    padding: 16px;
}

element selected {
    background-color: #7aa2f7;
    text-color: #1a1b26;
}
ROFI_THEME

# Create dunst config
section "Creating dunst notification configuration..."
mkdir -p ~/.config/dunst
cat > ~/.config/dunst/dunstrc << 'DUNST_EOF'
[global]
    monitor = 0
    follow = none
    width = 300
    height = 300
    origin = top-right
    offset = 10x50
    scale = 0
    notification_limit = 0
    progress_bar = true
    progress_bar_height = 10
    progress_bar_frame_width = 1
    progress_bar_min_width = 150
    progress_bar_max_width = 300
    indicate_hidden = yes
    transparency = 0
    notification_height = 0
    separator_height = 2
    padding = 8
    horizontal_padding = 8
    text_icon_padding = 0
    frame_width = 3
    frame_color = "#7aa2f7"
    separator_color = frame
    sort = yes
    font = JetBrainsMono Nerd Font 10
    line_height = 0
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes
    icon_position = left
    min_icon_size = 0
    max_icon_size = 32
    sticky_history = yes
    history_length = 20
    dmenu = /usr/bin/dmenu -p dunst:
    browser = /usr/bin/xdg-open
    always_run_script = true
    title = Dunst
    class = Dunst
    corner_radius = 10
    ignore_dbusclose = false
    force_xwayland = false
    force_xinerama = false
    mouse_left_click = close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all

[experimental]
    per_monitor_dpi = false

[urgency_low]
    background = "#1a1b26"
    foreground = "#c0caf5"
    timeout = 10

[urgency_normal]
    background = "#1a1b26"
    foreground = "#c0caf5"
    timeout = 10

[urgency_critical]
    background = "#f7768e"
    foreground = "#1a1b26"
    frame_color = "#f7768e"
    timeout = 0
DUNST_EOF

# Disable the auto-start service after completion
section "Disabling auto-start service..."
sudo systemctl disable arch-post-install.service

# Create completion indicator
section "Setup completed successfully!"
log "Hyprland setup completed for Dênio Barbosa Júnior!"
log "Machine: penn | User: deniojr | Timezone: São Paulo (-3 UTC)"
log "Keyboard: US International (for ç, à, è, ì, ò, ù characters)"
log ""
log "Installation summary:"
log "✅ Hyprland with enhanced theming"
log "✅ Multiple terminals: kitty, alacritty, wezterm"
log "✅ Development tools: Go, Rust, Python, PostgreSQL, Docker"
log "✅ Browsers: Firefox, Chromium, Brave, Chrome"
log "✅ Applications: Discord, Notion, VS Code, Cursor, etc."
log "✅ Gaming: Steam, Wine, Lutris, Heroic Games"
log "✅ Media: VLC, MPV, Spotify, OBS"
log ""
warn "Rebooting in 30 seconds to start Hyprland..."
warn "After reboot, you can start Hyprland with: Hyprland"

# Auto reboot after setup
sleep 30
sudo reboot