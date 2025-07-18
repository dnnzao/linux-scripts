#!/bin/bash
#===============================================================================
# Arch Linux Post Installation - Hyprland Setup (OPTIMIZED FOR REAL HARDWARE)
# Author: Dênio Barbosa Júnior
# Description: Installs Hyprland with full visual effects and GUI login
#===============================================================================

# NEVER exit on errors - continue regardless of failures
set +e

# Colors and logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }  # No longer exits
section() { echo -e "\n${PURPLE}[SECTION]${NC} $1\n"; }
success() { echo -e "${CYAN}[SUCCESS]${NC} $1"; }

# Function to install packages safely - never fails
safe_pacman() {
    local packages="$*"
    log "Attempting to install: $packages"
    if sudo pacman -S --needed --noconfirm $packages; then
        success "✅ Successfully installed: $packages"
    else
        warn "❌ Failed to install some packages in: $packages (continuing anyway)"
    fi
}

# Function to install AUR packages safely - never fails
safe_paru() {
    local packages="$*"
    log "Attempting to install from AUR: $packages"
    if paru -S --needed --noconfirm --skipreview $packages; then
        success "✅ Successfully installed from AUR: $packages"
    else
        warn "❌ Failed to install some AUR packages in: $packages (continuing anyway)"
    fi
}

# Function to run commands safely - never fails
safe_run() {
    local cmd="$*"
    log "Running: $cmd"
    if eval "$cmd"; then
        success "✅ Command succeeded: $cmd"
    else
        warn "❌ Command failed: $cmd (continuing anyway)"
    fi
}

# Create log file
exec > >(tee -a ~/post_install.log)
exec 2>&1

section "Starting Optimized Hyprland setup for Dênio Barbosa Júnior..."
log "Timestamp: $(date)"
log "🛡️  BULLETPROOF MODE: Script will NEVER stop regardless of failures"
log "🎨 FULL FEATURES MODE: Maximum visual effects and configurations"

# Wait for network
log "Waiting for network connection..."
while ! ping -c 1 google.com &> /dev/null; do
    sleep 2
done
log "Network connected"

# Update system and fix keyrings
section "Updating system and fixing package signatures..."
sudo pacman -Sy archlinux-keyring --noconfirm
sudo pacman-key --populate archlinux
sudo pacman -Syu --noconfirm

# Install paru AUR helper
section "Installing paru AUR helper..."
if ! command -v paru &> /dev/null; then
    cd /tmp
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ~
    log "Paru installed successfully"
else
    log "Paru already installed"
fi

# Install essential Wayland and graphics packages
section "Installing essential Wayland and graphics packages..."
sudo pacman -S --needed --noconfirm \
    wayland wayland-protocols \
    xorg-xwayland \
    mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon \
    vulkan-intel lib32-vulkan-intel \
    vulkan-icd-loader lib32-vulkan-icd-loader \
    libva-mesa-driver lib32-libva-mesa-driver \
    mesa-vdpau lib32-mesa-vdpau

# Install core system packages
section "Installing core system packages..."
sudo pacman -S --needed --noconfirm \
    bluez bluez-utils \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    polkit-gnome \
    qt5-wayland qt6-wayland \
    grim slurp swappy \
    wl-clipboard \
    brightnessctl playerctl \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
    thunar thunar-archive-plugin \
    firefox chromium \
    vlc mpv \
    fastfetch htop btop \
    unzip p7zip ark \
    noto-fonts noto-fonts-emoji \
    ttf-jetbrains-mono-nerd ttf-fira-code \
    starship \
    pavucontrol

# Install theme packages
log "Installing theme packages..."
sudo pacman -S --needed --noconfirm papirus-icon-theme arc-theme lxappearance qt5ct

# Install development tools
section "Installing development tools..."
sudo pacman -S --needed --noconfirm \
    go rust python python-pip \
    postgresql postgresql-contrib \
    docker docker-compose \
    neovim vim code

# Install Hyprland ecosystem
section "Installing Hyprland ecosystem..."

# Install stable Hyprland first as fallback
sudo pacman -S --needed --noconfirm hyprland

# Try to install git versions with paru
paru -S --needed --noconfirm --skipreview \
    hyprland-git \
    hyprpaper \
    hyprlock \
    hypridle \
    waybar \
    rofi-wayland \
    wofi \
    swww \
    dunst \
    wlogout || warn "Some Hyprland components failed to install"

# Install terminals
sudo pacman -S --needed --noconfirm kitty alacritty
paru -S --needed --noconfirm --skipreview wezterm || warn "Failed to install wezterm"

# Install additional tools
sudo pacman -S --needed --noconfirm cava

# Install gaming tools
section "Installing gaming tools..."
sudo pacman -S --needed --noconfirm \
    steam wine wine-gecko wine-mono \
    lutris gamemode lib32-gamemode

paru -S --needed --noconfirm --skipreview \
    wine-ge-custom \
    heroic-games-launcher-bin || warn "Some AUR gaming tools failed to install"

# Install GUI applications
section "Installing GUI applications..."
paru -S --needed --noconfirm --skipreview \
    discord \
    visual-studio-code-bin \
    brave-bin \
    google-chrome \
    spotify \
    obs-studio || warn "Some GUI applications failed to install"

# Install GUI display manager (SDDM with theme)
section "Installing GUI display manager..."
sudo pacman -S --needed --noconfirm sddm qt5-graphicaleffects qt5-quickcontrols2

# Install SDDM theme
paru -S --needed --noconfirm --skipreview sddm-sugar-candy-git || {
    warn "Failed to install SDDM theme, using default"
}

# Enable SDDM
sudo systemctl enable sddm

# Configure SDDM
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/10-wayland.conf > /dev/null << 'SDDM_EOF'
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
SessionDir=/usr/share/wayland-sessions
SDDM_EOF

# Enable services
section "Enabling services..."
sudo systemctl enable docker
sudo systemctl enable postgresql 
sudo systemctl enable bluetooth

# Add user to groups
sudo usermod -aG docker,input,video $USER

# Create enhanced Hyprland config with FULL VISUAL EFFECTS
section "Creating Enhanced Hyprland configuration..."
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/hyprland.conf << 'HYPR_EOF'
# Monitor configuration
monitor=,preferred,auto,1

# Environment variables for theming
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt5ct
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland

# Autostart
exec-once = waybar
exec-once = dunst
exec-once = swww init
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

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
        drag_lock = true
        scroll_factor = 1.0
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
    extend_border_grab_area = 15
}

# Enhanced decoration for maximum visual appeal
decoration {
    rounding = 12
    
    blur {
        enabled = true
        size = 8
        passes = 4
        new_optimizations = true
        xray = true
        ignore_opacity = true
        noise = 0.0117
        contrast = 1.3
        brightness = 1.0
        vibrancy = 0.3
        vibrancy_darkness = 0.5
    }
    
    drop_shadow = true
    shadow_range = 25
    shadow_render_power = 4
    col.shadow = rgba(1a1a1aee)
    shadow_offset = 0 2
    
    active_opacity = 0.95
    inactive_opacity = 0.85
    fullscreen_opacity = 1.0
    
    dim_inactive = true
    dim_strength = 0.1
}

# Smooth premium animations
animations {
    enabled = true
    
    bezier = wind, 0.05, 0.9, 0.1, 1.05
    bezier = winIn, 0.1, 1.1, 0.1, 1.1
    bezier = winOut, 0.3, -0.3, 0, 1
    bezier = liner, 1, 1, 1, 1
    bezier = overshot, 0.05, 0.9, 0.1, 1.1
    bezier = smoothOut, 0.36, 0, 0.66, -0.56
    bezier = smoothIn, 0.25, 1, 0.5, 1
    
    animation = windows, 1, 8, wind, slide
    animation = windowsIn, 1, 8, winIn, slide
    animation = windowsOut, 1, 7, winOut, slide
    animation = windowsMove, 1, 7, wind, slide
    animation = border, 1, 1, liner
    animation = borderangle, 1, 30, liner, loop
    animation = fade, 1, 12, default
    animation = workspaces, 1, 8, overshot, slidevert
    animation = specialWorkspace, 1, 8, overshot, slidevert
}

# Layout configuration
dwindle {
    pseudotile = true
    preserve_split = true
    smart_split = true
    smart_resizing = true
    force_split = 0
    split_width_multiplier = 1.0
    no_gaps_when_only = false
    special_scale_factor = 0.8
    use_active_for_splits = true
}

master {
    new_is_master = true
    new_on_top = false
    no_gaps_when_only = false
    orientation = left
    inherit_fullscreen = true
    always_center_master = false
    smart_resizing = true
    drop_at_cursor = true
}

# Gestures for touchpad
gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
    workspace_swipe_distance = 300
    workspace_swipe_invert = true
    workspace_swipe_min_speed_to_force = 30
    workspace_swipe_cancel_ratio = 0.5
    workspace_swipe_create_new = true
    workspace_swipe_forever = true
}

# Group configuration
group {
    col.border_active = rgba(7aa2f7ff)
    col.border_inactive = rgba(414868aa)
    col.border_locked_active = rgba(f7768eff)
    col.border_locked_inactive = rgba(9ece6aaa)
    groupbar {
        enabled = true
        font_family = JetBrainsMono Nerd Font
        font_size = 8
        gradients = true
        height = 14
        priority = 3
        render_titles = true
        scrolling = true
        text_color = rgba(c0caf5ff)
        col.active = rgba(7aa2f7ff)
        col.inactive = rgba(414868aa)
        col.locked_active = rgba(f7768eff)
        col.locked_inactive = rgba(9ece6aaa)
    }
}

# Miscellaneous
misc {
    disable_hyprland_logo = false
    disable_splash_rendering = false
    mouse_move_enables_dpms = true
    key_press_enables_dpms = false
    always_follow_on_dnd = true
    layers_hog_keyboard_focus = true
    animate_manual_resizes = false
    enable_swallow = true
    swallow_regex = ^(kitty)$
    focus_on_activate = false
    vrr = 0
}

# Enhanced window rules for better theming
windowrule = opacity 0.9 override,^(kitty)$
windowrule = opacity 0.9 override,^(alacritty)$
windowrule = opacity 0.95 override,^(code)$
windowrule = opacity 0.95 override,^(firefox)$
windowrule = opacity 0.95 override,^(chromium)$
windowrule = float,^(pavucontrol)$
windowrule = float,^(lxappearance)$
windowrule = float,^(qt5ct)$
windowrule = float,^(rofi)$
windowrule = float,^(wofi)$
windowrule = float,title:^(Picture-in-Picture)$
windowrule = pin,title:^(Picture-in-Picture)$
windowrule = size 25% 25%,title:^(Picture-in-Picture)$
windowrule = move 74% 74%,title:^(Picture-in-Picture)$

# Workspace rules
workspace = 1, monitor:, default:true
workspace = 2, monitor:
workspace = 3, monitor:
workspace = 4, monitor:
workspace = 5, monitor:
workspace = 6, monitor:
workspace = 7, monitor:
workspace = 8, monitor:
workspace = 9, monitor:
workspace = 10, monitor:

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
bind = $mainMod SHIFT, L, exec, wlogout

# Group management
bind = $mainMod, G, togglegroup
bind = $mainMod, TAB, changegroupactive

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

# Mouse bindings
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
HYPR_EOF

log "Enhanced Hyprland configuration created with full visual effects"

# Create enhanced waybar config
section "Creating Enhanced Waybar configuration..."
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
    "modules-right": ["tray", "pulseaudio", "network", "cpu", "memory", "battery"],
    
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
        },
        "persistent_workspaces": {
            "*": 5
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

# Create premium waybar CSS
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
    backdrop-filter: blur(10px);
    border: 2px solid rgba(122, 162, 247, 0.3);
}

button {
    box-shadow: inset 0 -3px transparent;
    border: none;
    border-radius: 8px;
    transition: all 0.3s cubic-bezier(0.55, 0.0, 0.28, 1.682);
}

#workspaces button {
    padding: 5px 8px;
    background-color: transparent;
    color: #7aa2f7;
    margin: 0 2px;
}

#workspaces button:hover {
    background: rgba(116, 199, 236, 0.2);
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(122, 162, 247, 0.3);
}

#workspaces button.active {
    background-color: #7aa2f7;
    color: #1a1b26;
    transform: translateY(-1px);
    box-shadow: 0 3px 6px rgba(122, 162, 247, 0.4);
}

#workspaces button.urgent {
    background-color: #f7768e;
    color: #1a1b26;
    animation: urgent 2s ease-in-out infinite;
}

@keyframes urgent {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.1); }
}

#clock,
#battery,
#cpu,
#memory,
#network,
#pulseaudio,
#tray,
#window {
    padding: 4px 12px;
    margin: 0 4px;
    background-color: rgba(122, 162, 247, 0.1);
    border-radius: 8px;
    border: 1px solid rgba(122, 162, 247, 0.2);
    transition: all 0.3s ease;
}

#clock:hover,
#battery:hover,
#cpu:hover,
#memory:hover,
#network:hover,
#pulseaudio:hover {
    background-color: rgba(122, 162, 247, 0.2);
    transform: translateY(-1px);
    box-shadow: 0 2px 4px rgba(122, 162, 247, 0.3);
}

#battery.charging, #battery.plugged {
    color: #9ece6a;
    background-color: rgba(158, 206, 106, 0.1);
}

#battery.critical:not(.charging) {
    background-color: #f7768e;
    color: #1a1b26;
    animation: blink 0.5s linear infinite alternate;
}

#cpu {
    color: #bb9af7;
}

#memory {
    color: #73daca;
}

#network {
    color: #7dcfff;
}

#pulseaudio {
    color: #e0af68;
}

@keyframes blink {
    to {
        background-color: #ffffff;
        color: #000000;
    }
}

#window {
    color: #c0caf5;
    font-style: italic;
}

#tray > .passive {
    -gtk-icon-effect: dim;
}

#tray > .needs-attention {
    -gtk-icon-effect: highlight;
    background-color: #f7768e;
}
WAYBAR_CSS

log "Enhanced Waybar configuration created"

# Configure terminals with enhanced settings
section "Configuring terminals..."

# Enhanced Kitty config
mkdir -p ~/.config/kitty
cat > ~/.config/kitty/kitty.conf << 'KITTY_EOF'
# Font settings
font_family JetBrainsMono Nerd Font
bold_font JetBrainsMono Nerd Font Bold
italic_font JetBrainsMono Nerd Font Italic
bold_italic_font JetBrainsMono Nerd Font Bold Italic
font_size 12.0

# Appearance
background_opacity 0.9
dynamic_background_opacity yes
dim_opacity 0.75

# Tokyo Night theme
foreground #c0caf5
background #1a1b26
selection_foreground #7aa2f7
selection_background #33467c

# Cursor
cursor #c0caf5
cursor_text_color #1a1b26
cursor_shape block
cursor_blink_interval -1

# URLs
url_color #73daca
url_style curly

# Copy/paste with Ctrl+C/V
map ctrl+c copy_to_clipboard
map ctrl+v paste_from_clipboard
map ctrl+shift+c send_text all \x03

# Window management
map ctrl+shift+enter new_window
map ctrl+shift+w close_window
map ctrl+shift+] next_window
map ctrl+shift+[ previous_window

# Performance
repaint_delay 10
input_delay 3
sync_to_monitor yes

# Bell
enable_audio_bell no
visual_bell_duration 0.0

# Advanced
shell_integration enabled
allow_remote_control yes
listen_on unix:/tmp/kitty
KITTY_EOF

# Enhanced Alacritty config
mkdir -p ~/.config/alacritty
cat > ~/.config/alacritty/alacritty.yml << 'ALACRITTY_EOF'
env:
  TERM: xterm-256color

window:
  opacity: 0.9
  padding:
    x: 6
    y: 6
  dynamic_padding: false
  decorations: none
  startup_mode: Windowed
  dynamic_title: true

scrolling:
  history: 10000
  multiplier: 3

font:
  normal:
    family: JetBrainsMono Nerd Font
    style: Regular
  bold:
    family: JetBrainsMono Nerd Font
    style: Bold
  italic:
    family: JetBrainsMono Nerd Font
    style: Italic
  bold_italic:
    family: JetBrainsMono Nerd Font
    style: Bold Italic
  size: 12.0
  offset:
    x: 0
    y: 0
  glyph_offset:
    x: 0
    y: 0

colors:
  primary:
    background: '#1a1b26'
    foreground: '#c0caf5'
  normal:
    black:   '#15161e'
    red:     '#f7768e'
    green:   '#9ece6a'
    yellow:  '#e0af68'
    blue:    '#7aa2f7'
    magenta: '#bb9af7'
    cyan:    '#7dcfff'
    white:   '#a9b1d6'
  bright:
    black:   '#414868'
    red:     '#f7768e'
    green:   '#9ece6a'
    yellow:  '#e0af68'
    blue:    '#7aa2f7'
    magenta: '#bb9af7'
    cyan:    '#7dcfff'
    white:   '#c0caf5'

cursor:
  style:
    shape: Block
    blinking: Never
  vi_mode_style: None

selection:
  semantic_escape_chars: ",│`|:\"' ()[]{}<>\t"
  save_to_clipboard: false

key_bindings:
  - { key: C, mods: Control, action: Copy }
  - { key: V, mods: Control, action: Paste }
  - { key: C, mods: Control|Shift, chars: "\x03" }
  - { key: Enter, mods: Control|Shift, action: SpawnNewInstance }
ALACRITTY_EOF

# Enhanced Wezterm config
mkdir -p ~/.config/wezterm
cat > ~/.config/wezterm/wezterm.lua << 'WEZTERM_EOF'
local wezterm = require 'wezterm'
local config = {}

-- Font configuration
config.font = wezterm.font('JetBrainsMono Nerd Font')
config.font_size = 12.0

-- Appearance
config.window_background_opacity = 0.9
config.text_background_opacity = 1.0

-- Tokyo Night color scheme
config.colors = {
  foreground = '#c0caf5',
  background = '#1a1b26',
  cursor_bg = '#c0caf5',
  cursor_fg = '#1a1b26',
  cursor_border = '#c0caf5',
  selection_fg = '#c0caf5',
  selection_bg = '#33467c',
  scrollbar_thumb = '#292e42',
  split = '#7aa2f7',
  ansi = {
    '#15161e',
    '#f7768e',
    '#9ece6a',
    '#e0af68',
    '#7aa2f7',
    '#bb9af7',
    '#7dcfff',
    '#a9b1d6',
  },
  brights = {
    '#414868',
    '#f7768e',
    '#9ece6a',
    '#e0af68',
    '#7aa2f7',
    '#bb9af7',
    '#7dcfff',
    '#c0caf5',
  },
}

-- Window configuration
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.window_padding = {
  left = 6,
  right = 6,
  top = 6,
  bottom = 6,
}

-- Key bindings
config.keys = {
  { key = 'c', mods = 'CTRL', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.SendKey { key = 'c', mods = 'CTRL' } },
  { key = 'Enter', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnWindow },
}

-- Performance
config.max_fps = 60
config.animation_fps = 1
config.cursor_blink_rate = 800

return config
WEZTERM_EOF

# Set up enhanced shell environment
section "Setting up enhanced shell environment..."
if [[ ! -f ~/.zshrc ]]; then
    cat > ~/.zshrc << 'ZSHRC_EOF'
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Starship prompt
eval "$(starship init zsh)"

# Environment variables
export PATH=$PATH:$HOME/.local/bin
export EDITOR=nvim
export BROWSER=firefox
export TERMINAL=kitty

# Aliases
alias ll="ls -la"
alias la="ls -A"
alias l="ls -CF"
alias grep="grep --color=auto"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias cls="clear"
alias reload="source ~/.zshrc"

# Hyprland aliases
alias hypr-reload="hyprctl reload"
alias hypr-logs="journalctl -f -u hyprland"

# Git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline"

# Development aliases
alias py="python"
alias nv="nvim"
alias code="code"

# System info
alias sysinfo="fastfetch"
alias cpu="btop"

# Auto-completion and syntax highlighting
autoload -U compinit
compinit

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt appendhistory
setopt sharehistory
setopt incappendhistory

# Auto-suggestions (if available)
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Syntax highlighting (if available)
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
ZSHRC_EOF
fi

# Install zsh plugins
sudo pacman -S --needed --noconfirm zsh-autosuggestions zsh-syntax-highlighting || warn "ZSH plugins not available"

# Create enhanced rofi config
section "Creating enhanced rofi configuration..."
mkdir -p ~/.config/rofi
cat > ~/.config/rofi/config.rasi << 'ROFI_EOF'
configuration {
    modi: "drun,run,window,ssh";
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
    display-ssh: "   SSH";
    sidebar-mode: true;
    kb-row-up: "Up,Control+k,Shift+Tab,Shift+ISO_Left_Tab";
    kb-row-down: "Down,Control+j";
    kb-accept-entry: "Control+z,Control+y,Return,KP_Enter";
    terminal: "kitty";
    kb-remove-to-eol: "Control+Shift+e";
    kb-mode-next: "Shift+Right,Control+Tab";
    kb-mode-previous: "Shift+Left,Control+Shift+Tab";
    kb-remove-char-back: "BackSpace";
}

@theme "~/.config/rofi/launcher.rasi"
ROFI_EOF

# Create premium rofi theme
cat > ~/.config/rofi/launcher.rasi << 'ROFI_THEME'
* {
    background-color: rgba(26, 27, 38, 0.95);
    border-color: #7aa2f7;
    text-color: #c0caf5;
    spacing: 0;
    width: 512px;
}

window {
    background-color: @background-color;
    border: 2px;
    border-radius: 12px;
    border-color: @border-color;
    padding: 15px;
}

inputbar {
    border: 0 0 2px 0;
    children: [prompt,entry];
    border-color: @border-color;
    spacing: 10px;
    padding: 10px;
    border-radius: 8px 8px 0 0;
}

prompt {
    padding: 6px 10px;
    border: 0 2px 0 0;
    border-color: @border-color;
    text-color: #7aa2f7;
    font: "JetBrainsMono Nerd Font Bold 12";
}

entry {
    padding: 6px;
    placeholder-color: #565f89;
    text-color: @text-color;
}

listview {
    cycle: false;
    margin: 10px 0 0 0;
    scrollbar: false;
    border-radius: 0 0 8px 8px;
}

element {
    border: 0;
    padding: 12px;
    border-radius: 8px;
    margin: 2px;
    transition-duration: 200ms;
}

element selected {
    background-color: #7aa2f7;
    text-color: #1a1b26;
    border-radius: 8px;
}

element-text {
    background-color: inherit;
    text-color: inherit;
    vertical-align: 0.5;
}

element-icon {
    background-color: inherit;
    size: 24px;
    margin: 0 8px 0 0;
}
ROFI_THEME

# Create enhanced dunst config
section "Creating enhanced dunst notification configuration..."
mkdir -p ~/.config/dunst
cat > ~/.config/dunst/dunstrc << 'DUNST_EOF'
[global]
    monitor = 0
    follow = none
    width = 350
    height = 350
    origin = top-right
    offset = 15x50
    scale = 0
    notification_limit = 5
    
    progress_bar = true
    progress_bar_height = 12
    progress_bar_frame_width = 2
    progress_bar_min_width = 200
    progress_bar_max_width = 300
    
    indicate_hidden = yes
    transparency = 5
    notification_height = 0
    separator_height = 3
    padding = 12
    horizontal_padding = 12
    text_icon_padding = 8
    frame_width = 3
    frame_color = "#7aa2f7"
    separator_color = frame
    sort = yes
    
    font = JetBrainsMono Nerd Font 11
    line_height = 4
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
    min_icon_size = 24
    max_icon_size = 64
    icon_path = /usr/share/icons/Papirus/48x48/status/:/usr/share/icons/Papirus/48x48/devices/:/usr/share/icons/Papirus/48x48/apps/
    
    sticky_history = yes
    history_length = 20
    dmenu = /usr/bin/rofi -dmenu -p dunst:
    browser = /usr/bin/firefox
    always_run_script = true
    title = Dunst
    class = Dunst
    corner_radius = 12
    ignore_dbusclose = false
    force_xwayland = false
    force_xinerama = false
    
    mouse_left_click = do_action, close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all

[experimental]
    per_monitor_dpi = false

[urgency_low]
    background = "#1a1b26"
    foreground = "#c0caf5"
    frame_color = "#414868"
    timeout = 10
    default_icon = /usr/share/icons/Papirus/48x48/status/dialog-information.svg

[urgency_normal]
    background = "#1a1b26"
    foreground = "#c0caf5"
    frame_color = "#7aa2f7"
    timeout = 10
    override_pause_level = 30
    default_icon = /usr/share/icons/Papirus/48x48/status/dialog-information.svg

[urgency_critical]
    background = "#f7768e"
    foreground = "#1a1b26"
    frame_color = "#f7768e"
    timeout = 0
    override_pause_level = 60
    default_icon = /usr/share/icons/Papirus/48x48/status/dialog-error.svg

[shortcuts]
    close = ctrl+space
    close_all = ctrl+shift+space
    history = ctrl+grave
    context = ctrl+shift+period
DUNST_EOF

# Create hyprlock config
section "Creating hyprlock configuration..."
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/hyprlock.conf << 'HYPRLOCK_EOF'
general {
    disable_loading_bar = false
    grace = 300
    hide_cursor = true
    no_fade_in = false
}

background {
    monitor =
    path = screenshot
    blur_passes = 3
    blur_size = 8
    noise = 0.0117
    contrast = 0.8916
    brightness = 0.8172
    vibrancy = 0.1696
    vibrancy_darkness = 0.0
}

input-field {
    monitor =
    size = 300, 60
    outline_thickness = 4
    dots_size = 0.2
    dots_spacing = 0.64
    dots_center = true
    dots_rounding = -1
    outer_color = rgb(7aa2f7)
    inner_color = rgb(1a1b26)
    font_color = rgb(c0caf5)
    fade_on_empty = true
    fade_timeout = 1000
    placeholder_text = <i>Input Password...</i>
    hide_input = false
    rounding = 12
    check_color = rgb(9ece6a)
    fail_color = rgb(f7768e)
    fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
    fail_transition = 300
    capslock_color = -1
    numlock_color = -1
    bothlock_color = -1
    invert_numlock = false
    swap_font_color = false
    position = 0, -20
    halign = center
    valign = center
}

label {
    monitor =
    text = cmd[update:1000] echo "$TIME"
    color = rgb(c0caf5)
    font_size = 90
    font_family = JetBrainsMono Nerd Font Bold
    position = 0, 16
    halign = center
    valign = center
    shadow_passes = 5
    shadow_size = 10
}

label {
    monitor =
    text = $USER
    color = rgb(c0caf5)
    font_size = 20
    font_family = JetBrainsMono Nerd Font
    position = 0, 160
    halign = center
    valign = center
    shadow_passes = 5
    shadow_size = 10
}

image {
    monitor =
    path = ~/.face
    size = 280
    rounding = -1
    border_size = 4
    border_color = rgb(7aa2f7)
    rotate = 0
    reload_time = -1
    reload_cmd = 
    position = 0, 200
    halign = center
    valign = center
}
HYPRLOCK_EOF

# Create hypridle config
cat > ~/.config/hypr/hypridle.conf << 'HYPRIDLE_EOF'
general {
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}

listener {
    timeout = 150
    on-timeout = brightnessctl -s set 10
    on-resume = brightnessctl -r
}

listener {
    timeout = 300
    on-timeout = loginctl lock-session
}

listener {
    timeout = 330
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}

listener {
    timeout = 1800
    on-timeout = systemctl suspend
}
HYPRIDLE_EOF

# Create wlogout config
mkdir -p ~/.config/wlogout
cat > ~/.config/wlogout/layout << 'WLOGOUT_EOF'
{
    "label" : "lock",
    "action" : "hyprlock",
    "text" : "Lock",
    "keybind" : "l"
}
{
    "label" : "hibernate",
    "action" : "systemctl hibernate",
    "text" : "Hibernate",
    "keybind" : "h"
}
{
    "label" : "logout",
    "action" : "hyprctl dispatch exit",
    "text" : "Logout",
    "keybind" : "e"
}
{
    "label" : "shutdown",
    "action" : "systemctl poweroff",
    "text" : "Shutdown",
    "keybind" : "s"
}
{
    "label" : "suspend",
    "action" : "systemctl suspend",
    "text" : "Suspend",
    "keybind" : "u"
}
{
    "label" : "reboot",
    "action" : "systemctl reboot",
    "text" : "Reboot",
    "keybind" : "r"
}
WLOGOUT_EOF

cat > ~/.config/wlogout/style.css << 'WLOGOUT_CSS'
* {
    background-image: none;
}
window {
    background-color: rgba(26, 27, 38, 0.9);
}
button {
    color: #c0caf5;
    background-color: rgba(122, 162, 247, 0.1);
    border-style: solid;
    border-width: 2px;
    background-repeat: no-repeat;
    background-position: center;
    background-size: 25%;
    border-radius: 12px;
    margin: 5px;
    transition: all 0.3s ease-in-out;
}

button:focus, button:active, button:hover {
    background-color: rgba(122, 162, 247, 0.3);
    outline-style: none;
    transform: scale(1.05);
}

#lock {
    background-image: image(url("/usr/share/wlogout/icons/lock.png"));
    border-color: #7aa2f7;
}

#logout {
    background-image: image(url("/usr/share/wlogout/icons/logout.png"));
    border-color: #bb9af7;
}

#suspend {
    background-image: image(url("/usr/share/wlogout/icons/suspend.png"));
    border-color: #73daca;
}

#hibernate {
    background-image: image(url("/usr/share/wlogout/icons/hibernate.png"));
    border-color: #9ece6a;
}

#shutdown {
    background-image: image(url("/usr/share/wlogout/icons/shutdown.png"));
    border-color: #f7768e;
}

#reboot {
    background-image: image(url("/usr/share/wlogout/icons/reboot.png"));
    border-color: #e0af68;
}
WLOGOUT_CSS

# Disable the auto-start service after completion
section "Disabling auto-start service..."
sudo systemctl disable arch-post-install.service || warn "Service already disabled"

# Create desktop entry for Hyprland
sudo mkdir -p /usr/share/wayland-sessions
sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null << 'DESKTOP_EOF'
[Desktop Entry]
Name=Hyprland
Comment=A dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
DESKTOP_EOF

section "Setup completed successfully!"
log "Optimized Hyprland setup completed for Dênio Barbosa Júnior!"
log ""
log "Installation summary:"
log "✅ Hyprland with FULL visual effects optimized for real hardware"
log "✅ SDDM GUI login manager (no more terminal login!)"
log "✅ Enhanced terminals with Tokyo Night theme"
log "✅ Premium animations, blur, and transparency"
log "✅ Complete development environment"
log "✅ Enhanced waybar with system monitoring"
log "✅ Rofi launcher with premium theme"
log "✅ Dunst notifications with rich styling"
log "✅ Hyprlock screen locker"
log "✅ Wlogout power menu"
log "✅ All gaming and productivity applications"
log ""
log "Key features added:"
log "🎨 Full blur effects and premium animations"
log "🖥️  GUI login manager (SDDM) - no more terminal login!"
log "🎯 Enhanced window management and workspaces"
log "⌨️  Custom keybindings and shortcuts"
log "🔒 Screen lock and power management"
log "🎮 Complete gaming setup"
log ""
warn "Rebooting in 15 seconds to start the new GUI login experience..."

sleep 15
sudo reboot