#!/bin/bash
#===============================================================================
# Arch Linux Post Installation - ULTIMATE Hyprland Setup
# Author: Dênio Barbosa Júnior
# Description: FULL FEATURES + BULLETPROOF - Never stops, maximum visual effects
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

section "🚀 ULTIMATE Hyprland Setup for Dênio Barbosa Júnior 🚀"
log "Timestamp: $(date)"
log "🛡️  BULLETPROOF MODE: Script will NEVER stop regardless of failures"
log "🎨 FULL FEATURES MODE: Maximum visual effects and configurations"

# Wait for network with timeout
log "Waiting for network connection..."
network_attempts=0
while ! ping -c 1 google.com &> /dev/null; do
    sleep 2
    network_attempts=$((network_attempts + 1))
    if [ $network_attempts -gt 30 ]; then
        warn "Network connection timeout after 60 seconds - continuing anyway"
        break
    fi
done
if ping -c 1 google.com &> /dev/null; then
    success "Network connected successfully"
else
    warn "No network - some packages may fail but script continues"
fi

# Update system and fix keyrings - continue regardless of failures
section "Updating system and fixing package signatures..."
safe_run "sudo pacman -Sy archlinux-keyring --noconfirm"
safe_run "sudo pacman-key --populate archlinux"
safe_run "sudo pacman -Syu --noconfirm"

# Install paru AUR helper - with full error handling
section "Installing paru AUR helper..."
if ! command -v paru &> /dev/null; then
    safe_run "cd /tmp"
    safe_pacman git base-devel
    if safe_run "git clone https://aur.archlinux.org/paru.git"; then
        safe_run "cd paru"
        if safe_run "makepkg -si --noconfirm"; then
            success "Paru installed successfully"
        else
            warn "Paru installation failed - will use yay or pacman as fallback"
            # Try installing yay as fallback
            safe_run "cd /tmp"
            if safe_run "git clone https://aur.archlinux.org/yay.git"; then
                safe_run "cd yay"
                safe_run "makepkg -si --noconfirm"
            fi
        fi
    fi
    safe_run "cd ~"
else
    success "Paru already installed"
fi

# Install essential Wayland and graphics packages - split into smaller groups
section "Installing essential Wayland and graphics packages..."
safe_pacman wayland wayland-protocols
safe_pacman xorg-xwayland
safe_pacman mesa lib32-mesa
safe_pacman vulkan-radeon lib32-vulkan-radeon
safe_pacman vulkan-intel lib32-vulkan-intel
safe_pacman vulkan-icd-loader lib32-vulkan-icd-loader
safe_pacman libva-mesa-driver lib32-libva-mesa-driver
safe_pacman mesa-vdpau lib32-mesa-vdpau

# Install core system packages - split into logical groups
section "Installing core system packages..."
safe_pacman bluez bluez-utils
safe_pacman xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
safe_pacman polkit-gnome
safe_pacman qt5-wayland qt6-wayland
safe_pacman grim slurp swappy
safe_pacman wl-clipboard
safe_pacman brightnessctl playerctl
safe_pacman pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
safe_pacman thunar thunar-archive-plugin
safe_pacman firefox chromium
safe_pacman vlc mpv
safe_pacman fastfetch htop btop
safe_pacman unzip p7zip ark
safe_pacman noto-fonts noto-fonts-emoji
safe_pacman ttf-jetbrains-mono-nerd ttf-fira-code
safe_pacman starship
safe_pacman pavucontrol

# Install theme packages - each separately to avoid group failures
log "Installing theme packages..."
safe_pacman papirus-icon-theme
safe_pacman arc-theme
safe_pacman lxappearance
safe_pacman qt5ct

# Install development tools - each separately
section "Installing development tools..."
safe_pacman go
safe_pacman rust
safe_pacman python python-pip
safe_pacman postgresql postgresql-contrib
safe_pacman docker docker-compose
safe_pacman neovim vim
safe_pacman code

# Install Hyprland ecosystem - with multiple fallbacks
section "Installing Hyprland ecosystem..."

# Install stable Hyprland first as primary option
safe_pacman hyprland

# Try to install git versions with paru/yay - each package separately
if command -v paru &> /dev/null; then
    safe_paru hyprland-git
    safe_paru hyprpaper
    safe_paru hyprlock
    safe_paru hypridle
    safe_paru waybar
    safe_paru rofi-wayland
    safe_paru wofi
    safe_paru swww
    safe_paru dunst
    safe_paru wlogout
    safe_paru eww-wayland
    safe_paru cava
elif command -v yay &> /dev/null; then
    safe_run "yay -S --needed --noconfirm hyprland-git"
    safe_run "yay -S --needed --noconfirm hyprpaper"
    safe_run "yay -S --needed --noconfirm hyprlock"
    safe_run "yay -S --needed --noconfirm hypridle"
    safe_run "yay -S --needed --noconfirm waybar"
    safe_run "yay -S --needed --noconfirm rofi-wayland"
    safe_run "yay -S --needed --noconfirm wofi"
    safe_run "yay -S --needed --noconfirm swww"
    safe_run "yay -S --needed --noconfirm dunst"
    safe_run "yay -S --needed --noconfirm wlogout"
    safe_run "yay -S --needed --noconfirm eww-wayland"
    safe_run "yay -S --needed --noconfirm cava"
else
    warn "No AUR helper available - installing available packages from official repos"
    safe_pacman waybar
    safe_pacman rofi
    safe_pacman wofi
    safe_pacman dunst
    safe_pacman cava
fi

# Install terminals - each separately
safe_pacman kitty
safe_pacman alacritty
safe_paru wezterm

# Install gaming tools - each separately to avoid group failures
section "Installing gaming tools..."
safe_pacman steam
safe_pacman wine wine-gecko wine-mono
safe_pacman lutris
safe_pacman gamemode lib32-gamemode

safe_paru wine-ge-custom
safe_paru heroic-games-launcher-bin

# Install GUI applications - each separately
section "Installing GUI applications..."
safe_paru discord
safe_paru notion-app-enhanced
safe_paru visual-studio-code-bin
safe_paru cursor-bin
safe_paru brave-bin
safe_paru google-chrome
safe_paru sublime-text-4
safe_paru spotify
safe_paru obs-studio

# Install GUI display manager with premium themes - with fallbacks
section "Installing GUI display manager with themes..."
safe_pacman sddm qt5-graphicaleffects qt5-quickcontrols2

# Try to install premium SDDM themes
safe_paru sddm-sugar-candy-git
safe_paru sddm-theme-corners-git

# Enable services - continue even if some fail
section "Enabling services..."
safe_run "sudo systemctl enable sddm"
safe_run "sudo systemctl enable docker"
safe_run "sudo systemctl enable postgresql"
safe_run "sudo systemctl enable bluetooth"

# Add user to groups - continue even if fails
safe_run "sudo usermod -aG docker,input,video $USER"

# Configure SDDM with premium theme - continue even if fails
safe_run "sudo mkdir -p /etc/sddm.conf.d"
cat > /tmp/sddm_config << 'SDDM_EOF'
[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
SessionDir=/usr/share/wayland-sessions

[Theme]
Current=sugar-candy
SDDM_EOF

safe_run "sudo cp /tmp/sddm_config /etc/sddm.conf.d/10-wayland.conf"

# Create ULTIMATE Hyprland config with MAXIMUM visual effects
section "Creating ULTIMATE Hyprland configuration..."
safe_run "mkdir -p ~/.config/hypr"
cat > ~/.config/hypr/hyprland.conf << 'HYPR_EOF'
# Monitor configuration with advanced settings
monitor=,preferred,auto,1
monitor=eDP-1,preferred,auto,1
monitor=HDMI-A-1,preferred,auto,1
monitor=DP-1,preferred,auto,1

# Environment variables for maximum theming
env = XCURSOR_SIZE,24
env = XCURSOR_THEME,Bibata-Modern-Ice
env = QT_QPA_PLATFORMTHEME,qt5ct
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
env = GDK_BACKEND,wayland,x11
env = SDL_VIDEODRIVER,wayland
env = CLUTTER_BACKEND,wayland
env = QT_QPA_PLATFORM,wayland;xcb
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = QT_AUTO_SCREEN_SCALE_FACTOR,1
env = MOZ_ENABLE_WAYLAND,1

# Autostart with comprehensive setup
exec-once = waybar
exec-once = dunst
exec-once = swww init
exec-once = swww img ~/Pictures/wallpaper.jpg || swww img /usr/share/backgrounds/default.jpg
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = hypridle
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store

# Input configuration for US International keyboard with advanced settings
input {
    kb_layout = us
    kb_variant = intl
    kb_model =
    kb_options = grp:alt_shift_toggle,caps:escape
    kb_rules =
    
    follow_mouse = 1
    mouse_refocus = true
    
    touchpad {
        natural_scroll = true
        tap-to-click = true
        tap-and-drag = true
        drag_lock = true
        disable_while_typing = true
        middle_button_emulation = true
        clickfinger_behavior = true
        scroll_factor = 1.0
    }
    
    sensitivity = 0
    accel_profile = adaptive
    force_no_accel = false
}

# General settings (MAXIMUM ricing)
general {
    gaps_in = 8
    gaps_out = 15
    border_size = 3
    col.active_border = rgba(7aa2f7ff) rgba(bb9af7ff) rgba(9ece6aff) rgba(f7768eff) 45deg
    col.inactive_border = rgba(414868aa) rgba(24283baa) 45deg
    layout = dwindle
    allow_tearing = false
    resize_on_border = true
    extend_border_grab_area = 15
    hover_icon_on_border = true
    no_border_on_floating = false
}

# MAXIMUM decoration for ultimate visual appeal
decoration {
    rounding = 12
    
    blur {
        enabled = true
        size = 10
        passes = 5
        new_optimizations = true
        xray = true
        ignore_opacity = true
        noise = 0.0117
        contrast = 1.3
        brightness = 1.0
        vibrancy = 0.3
        vibrancy_darkness = 0.5
        special = false
        popups = true
        popups_ignorealpha = 0.2
    }
    
    drop_shadow = true
    shadow_range = 30
    shadow_render_power = 4
    col.shadow = rgba(1a1a1aee)
    col.shadow_inactive = rgba(1a1a1a77)
    shadow_offset = 0 2
    shadow_scale = 1.0
    
    active_opacity = 0.95
    inactive_opacity = 0.85
    fullscreen_opacity = 1.0
    
    dim_inactive = true
    dim_strength = 0.1
    dim_special = 0.2
    dim_around = 0.4
    
    screen_shader = ~/.config/hypr/shaders/blue_light.frag
}

# PREMIUM animations with custom bezier curves
animations {
    enabled = true
    first_launch_anim = true
    
    bezier = wind, 0.05, 0.9, 0.1, 1.05
    bezier = winIn, 0.1, 1.1, 0.1, 1.1
    bezier = winOut, 0.3, -0.3, 0, 1
    bezier = liner, 1, 1, 1, 1
    bezier = overshot, 0.05, 0.9, 0.1, 1.1
    bezier = smoothOut, 0.36, 0, 0.66, -0.56
    bezier = smoothIn, 0.25, 1, 0.5, 1
    bezier = realsmooth, 0.28, 0.29, 0.69, 1.08
    bezier = easeOutBack, 0.34, 1.56, 0.64, 1
    bezier = easeInOut, 0.42, 0, 0.58, 1
    
    animation = windows, 1, 8, wind, slide
    animation = windowsIn, 1, 8, winIn, slide
    animation = windowsOut, 1, 7, winOut, slide
    animation = windowsMove, 1, 7, wind, slide
    animation = border, 1, 1, liner
    animation = borderangle, 1, 30, liner, loop
    animation = fade, 1, 12, default
    animation = fadeIn, 1, 8, smoothIn
    animation = fadeOut, 1, 8, smoothOut
    animation = fadeSwitch, 1, 8, easeInOut
    animation = fadeShadow, 1, 8, easeInOut
    animation = fadeDim, 1, 8, easeInOut
    animation = workspaces, 1, 8, overshot, slidevert
    animation = specialWorkspace, 1, 8, overshot, slidevert
    animation = layers, 1, 8, easeOutBack, slide
}

# Layout configuration with advanced options
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
    default_split_ratio = 1.0
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
    mfact = 0.55
    allow_small_split = false
    special_scale_factor = 0.8
}

# Advanced gestures for touchpad
gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
    workspace_swipe_distance = 300
    workspace_swipe_invert = true
    workspace_swipe_min_speed_to_force = 30
    workspace_swipe_cancel_ratio = 0.5
    workspace_swipe_create_new = true
    workspace_swipe_direction_lock = true
    workspace_swipe_direction_lock_threshold = 10
    workspace_swipe_forever = true
    workspace_swipe_numbered = false
}

# Group configuration with advanced styling
group {
    col.border_active = rgba(7aa2f7ff) rgba(bb9af7ff) 45deg
    col.border_inactive = rgba(414868aa)
    col.border_locked_active = rgba(f7768eff) rgba(e0af68ff) 45deg
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
        col.active = rgba(7aa2f7ff) rgba(bb9af7ff) 45deg
        col.inactive = rgba(414868aa)
        col.locked_active = rgba(f7768eff) rgba(e0af68ff) 45deg
        col.locked_inactive = rgba(9ece6aaa)
    }
}

# Advanced miscellaneous settings
misc {
    disable_hyprland_logo = false
    disable_splash_rendering = false
    mouse_move_enables_dpms = true
    key_press_enables_dpms = false
    always_follow_on_dnd = true
    layers_hog_keyboard_focus = true
    animate_manual_resizes = false
    animate_mouse_windowdragging = true
    disable_autoreload = false
    enable_swallow = true
    swallow_regex = ^(kitty|alacritty|Alacritty)$
    swallow_exception_regex = ^(wev)$
    focus_on_activate = false
    mouse_move_focuses_monitor = true
    render_ahead_of_time = false
    render_ahead_safezone = 1
    vrr = 0
    vfr = true
    close_special_on_empty = true
    new_window_takes_over_fullscreen = 0
    enable_hyprcursor = true
    no_direct_scanout = true
    hide_cursor_on_touch = true
    suppress_portal_warnings = false
}

# Advanced binds configuration
binds {
    pass_mouse_when_bound = false
    scroll_event_delay = 300
    workspace_back_and_forth = false
    allow_workspace_cycles = false
    workspace_center_on = 0
    focus_preferred_method = 0
    ignore_group_lock = false
}

# Advanced xwayland settings
xwayland {
    use_nearest_neighbor = true
    force_zero_scaling = false
}

# Enhanced window rules for maximum theming
windowrule = opacity 0.9 override,^(kitty)$
windowrule = opacity 0.9 override,^(alacritty)$
windowrule = opacity 0.9 override,^(wezterm)$
windowrule = opacity 0.95 override,^(code)$
windowrule = opacity 0.95 override,^(Code)$
windowrule = opacity 0.95 override,^(firefox)$
windowrule = opacity 0.95 override,^(chromium)$
windowrule = opacity 0.95 override,^(brave-browser)$
windowrule = opacity 0.95 override,^(google-chrome)$
windowrule = opacity 0.9 override,^(thunar)$
windowrule = opacity 0.9 override,^(discord)$
windowrule = opacity 0.95 override,^(spotify)$
windowrule = opacity 0.95 override,^(notion-app-enhanced)$

windowrule = float,^(pavucontrol)$
windowrule = float,^(lxappearance)$
windowrule = float,^(qt5ct)$
windowrule = float,^(rofi)$
windowrule = float,^(wofi)$
windowrule = float,^(wlogout)$
windowrule = float,title:^(Picture-in-Picture)$
windowrule = float,title:^(Firefox — Sharing Indicator)$
windowrule = float,class:^(org.kde.polkit-kde-authentication-agent-1)$

windowrule = pin,title:^(Picture-in-Picture)$
windowrule = size 25% 25%,title:^(Picture-in-Picture)$
windowrule = move 74% 74%,title:^(Picture-in-Picture)$

# Gaming window rules
windowrule = fullscreen,^(steam_app_)
windowrule = monitor 1,^(steam_app_)
windowrule = workspace 5,^(steam)$
windowrule = workspace 5,^(lutris)$
windowrule = workspace 5,^(heroic)$

# IDE and development window rules
windowrule = workspace 2,^(code)$
windowrule = workspace 2,^(Code)$
windowrule = workspace 2,^(cursor)$
windowrule = workspace 2,^(sublime_text)$

# Browser window rules
windowrule = workspace 1,^(firefox)$
windowrule = workspace 1,^(chromium)$
windowrule = workspace 1,^(brave-browser)$
windowrule = workspace 1,^(google-chrome)$

# Communication window rules
windowrule = workspace 4,^(discord)$
windowrule = workspace 4,^(notion-app-enhanced)$

# Media window rules
windowrule = workspace 3,^(spotify)$
windowrule = workspace 3,^(vlc)$
windowrule = workspace 3,^(mpv)$
windowrule = workspace 3,^(obs)$

# Advanced layer rules
layerrule = blur,rofi
layerrule = blur,wofi
layerrule = blur,waybar
layerrule = blur,dunst
layerrule = blur,notifications
layerrule = ignorezero,waybar
layerrule = ignorezero,dunst

# Workspace rules with advanced configurations
workspace = 1, monitor:, default:true, gapsin:8, gapsout:15
workspace = 2, monitor:, gapsin:8, gapsout:15
workspace = 3, monitor:, gapsin:8, gapsout:15
workspace = 4, monitor:, gapsin:8, gapsout:15
workspace = 5, monitor:, gapsin:8, gapsout:15
workspace = 6, monitor:, gapsin:8, gapsout:15
workspace = 7, monitor:, gapsin:8, gapsout:15
workspace = 8, monitor:, gapsin:8, gapsout:15
workspace = 9, monitor:, gapsin:8, gapsout:15
workspace = 10, monitor:, gapsin:8, gapsout:15

# Special workspaces
workspace = special:magic, on-created-empty:kitty
workspace = special:files, on-created-empty:thunar
workspace = special:music, on-created-empty:spotify
workspace = special:chat, on-created-empty:discord

# Key bindings with comprehensive shortcuts
$mainMod = SUPER
$shiftMod = SUPER_SHIFT
$ctrlMod = SUPER_CTRL
$altMod = SUPER_ALT

# Application shortcuts
bind = $mainMod, Return, exec, kitty
bind = $shiftMod, Return, exec, alacritty
bind = $altMod, Return, exec, wezterm
bind = $mainMod, C, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, rofi -show drun
bind = $shiftMod, R, exec, wofi --show drun
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,
bind = $mainMod, F, fullscreen,
bind = $mainMod, L, exec, hyprlock
bind = $shiftMod, L, exec, wlogout
bind = $mainMod, Q, exec, wlogout

# Advanced application bindings
bind = $mainMod, B, exec, firefox
bind = $shiftMod, B, exec, brave
bind = $mainMod, D, exec, discord
bind = $mainMod, S, exec, spotify
bind = $mainMod, N, exec, notion-app-enhanced
bind = $ctrlMod, C, exec, code
bind = $ctrlMod, S, exec, sublime_text
bind = $mainMod, T, exec, telegram-desktop

# Group management
bind = $mainMod, G, togglegroup
bind = $mainMod, TAB, changegroupactive, f
bind = $shiftMod, TAB, changegroupactive, b
bind = $ctrlMod, G, moveoutofgroup
bind = $altMod, G, moveintogroup

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

# Move windows with vim keys
bind = $shiftMod, h, movewindow, l
bind = $shiftMod, l, movewindow, r
bind = $shiftMod, k, movewindow, u
bind = $shiftMod, j, movewindow, d

# Move windows with arrows
bind = $shiftMod, left, movewindow, l
bind = $shiftMod, right, movewindow, r
bind = $shiftMod, up, movewindow, u
bind = $shiftMod, down, movewindow, d

# Resize windows with vim keys
bind = $ctrlMod, h, resizeactive, -20 0
bind = $ctrlMod, l, resizeactive, 20 0
bind = $ctrlMod, k, resizeactive, 0 -20
bind = $ctrlMod, j, resizeactive, 0 20

# Resize windows with arrows
bind = $ctrlMod, left, resizeactive, -20 0
bind = $ctrlMod, right, resizeactive, 20 0
bind = $ctrlMod, up, resizeactive, 0 -20
bind = $ctrlMod, down, resizeactive, 0 20

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
bind = $shiftMod, 1, movetoworkspace, 1
bind = $shiftMod, 2, movetoworkspace, 2
bind = $shiftMod, 3, movetoworkspace, 3
bind = $shiftMod, 4, movetoworkspace, 4
bind = $shiftMod, 5, movetoworkspace, 5
bind = $shiftMod, 6, movetoworkspace, 6
bind = $shiftMod, 7, movetoworkspace, 7
bind = $shiftMod, 8, movetoworkspace, 8
bind = $shiftMod, 9, movetoworkspace, 9
bind = $shiftMod, 0, movetoworkspace, 10

# Move windows to workspace silently
bind = $ctrlMod, 1, movetoworkspacesilent, 1
bind = $ctrlMod, 2, movetoworkspacesilent, 2
bind = $ctrlMod, 3, movetoworkspacesilent, 3
bind = $ctrlMod, 4, movetoworkspacesilent, 4
bind = $ctrlMod, 5, movetoworkspacesilent, 5
bind = $ctrlMod, 6, movetoworkspacesilent, 6
bind = $ctrlMod, 7, movetoworkspacesilent, 7
bind = $ctrlMod, 8, movetoworkspacesilent, 8
bind = $ctrlMod, 9, movetoworkspacesilent, 9
bind = $ctrlMod, 0, movetoworkspacesilent, 10

# Volume and brightness controls
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
bind = , XF86MonBrightnessUp, exec, brightnessctl s 10%+
bind = , XF86MonBrightnessDown, exec, brightnessctl s 10%-

# Media keys
bind = , XF86AudioPlay, exec, playerctl play-pause
bind = , XF86AudioNext, exec, playerctl next
bind = , XF86AudioPrev, exec, playerctl previous
bind = , XF86AudioStop, exec, playerctl stop

# Advanced screenshot bindings
bind = , Print, exec, grim -g "$(slurp)" - | swappy -f -
bind = $mainMod, Print, exec, grim - | swappy -f -
bind = $shiftMod, S, exec, grim -g "$(slurp)" - | swappy -f -
bind = $ctrlMod, Print, exec, grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S.png')
bind = $altMod, Print, exec, grim ~/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S.png')

# Special workspaces (scratchpads)
bind = $mainMod, grave, togglespecialworkspace, magic
bind = $shiftMod, grave, movetoworkspace, special:magic
bind = $mainMod, F1, togglespecialworkspace, files
bind = $shiftMod, F1, movetoworkspace, special:files
bind = $mainMod, F2, togglespecialworkspace, music
bind = $shiftMod, F2, movetoworkspace, special:music
bind = $mainMod, F3, togglespecialworkspace, chat
bind = $shiftMod, F3, movetoworkspace, special:chat

# Workspace navigation
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1
bind = $altMod, TAB, workspace, e+1
bind = $altMod SHIFT, TAB, workspace, e-1

# Window management
bind = $mainMod, Space, centerwindow
bind = $shiftMod, F, fakefullscreen
bind = $mainMod, U, focusurgentorlast
bind = $mainMod, I, focuscurrentorlast

# Mouse bindings
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
bindm = $shiftMod, mouse:272, resizewindow

# Advanced key repeats for smoother experience
binde = $ctrlMod, h, resizeactive, -10 0
binde = $ctrlMod, l, resizeactive, 10 0
binde = $ctrlMod, k, resizeactive, 0 -10
binde = $ctrlMod, j, resizeactive, 0 10

# Submap for window operations
bind = $mainMod, W, submap, window
submap = window
bind = , F, fullscreen, 0
bind = , M, fullscreen, 1
bind = , P, pin
bind = , S, swapnext
bind = , O, toggleopaque
bind = , escape, submap, reset
submap = reset

# Submap for system operations
bind = $mainMod, Escape, submap, system
submap = system
bind = , L, exec, hyprlock
bind = , S, exec, systemctl suspend
bind = , R, exec, systemctl reboot
bind = , P, exec, systemctl poweroff
bind = , H, exec, systemctl hibernate
bind = , escape, submap, reset
submap = reset
HYPR_EOF

success "✅ ULTIMATE Hyprland configuration created with maximum visual effects"

# Create PREMIUM waybar config with advanced features
section "Creating PREMIUM Waybar configuration..."
safe_run "mkdir -p ~/.config/waybar"
cat > ~/.config/waybar/config << 'WAYBAR_EOF'
{
    "layer": "top",
    "position": "top",
    "height": 40,
    "spacing": 4,
    "margin-top": 8,
    "margin-left": 12,
    "margin-right": 12,
    "modules-left": ["custom/logo", "hyprland/workspaces", "hyprland/window", "hyprland/submap"],
    "modules-center": ["custom/weather", "clock", "custom/notification"],
    "modules-right": ["tray", "custom/wallpaper", "custom/theme", "idle_inhibitor", "pulseaudio", "network", "bluetooth", "cpu", "memory", "temperature", "backlight", "battery", "custom/power"],
    
    "custom/logo": {
        "format": " ",
        "tooltip": false,
        "on-click": "rofi -show drun"
    },
    
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
            "*": 10
        },
        "on-click": "activate",
        "on-scroll-up": "hyprctl dispatch workspace e+1",
        "on-scroll-down": "hyprctl dispatch workspace e-1"
    },
    
    "hyprland/window": {
        "format": "{}",
        "max-length": 50,
        "separate-outputs": true,
        "icon": true,
        "icon-size": 16
    },
    
    "hyprland/submap": {
        "format": "✨ {}",
        "max-length": 8,
        "tooltip": false
    },
    
    "clock": {
        "timezone": "America/Sao_Paulo",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format": "{:%H:%M}",
        "format-alt": "{:%Y-%m-%d}",
        "on-click-right": "gnome-calendar"
    },
    
    "custom/weather": {
        "format": "{}°",
        "tooltip": true,
        "interval": 300,
        "exec": "wttrbar --location 'Santa Luzia, MG'",
        "return-type": "json"
    },
    
    "custom/notification": {
        "tooltip": false,
        "format": "{icon}",
        "format-icons": {
            "notification": "<span foreground='red'><sup></sup></span>",
            "none": "",
            "dnd-notification": "<span foreground='red'><sup></sup></span>",
            "dnd-none": "",
            "inhibited-notification": "<span foreground='red'><sup></sup></span>",
            "inhibited-none": "",
            "dnd-inhibited-notification": "<span foreground='red'><sup></sup></span>",
            "dnd-inhibited-none": ""
        },
        "return-type": "json",
        "exec-if": "which swaync-client",
        "exec": "swaync-client -swb",
        "on-click": "swaync-client -t -sw",
        "on-click-right": "swaync-client -d -sw",
        "escape": true
    },
    
    "cpu": {
        "format": "{usage}% ",
        "tooltip": true,
        "interval": 2,
        "on-click": "kitty -e btop"
    },
    
    "memory": {
        "format": "{}% ",
        "tooltip": true,
        "interval": 2,
        "on-click": "kitty -e btop"
    },
    
    "temperature": {
        "thermal-zone": 2,
        "hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",
        "critical-threshold": 80,
        "format-critical": "{temperatureC}°C ",
        "format": "{temperatureC}°C ",
        "interval": 2
    },
    
    "backlight": {
        "device": "intel_backlight",
        "format": "{percent}% {icon}",
        "format-icons": ["", "", "", "", "", "", "", "", ""],
        "on-scroll-up": "brightnessctl set 1%+",
        "on-scroll-down": "brightnessctl set 1%-",
        "min-length": 6
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
        "format-icons": ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"],
        "on-click": "gnome-power-statistics"
    },
    
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "{ipaddr}/{cidr} ",
        "tooltip-format": "{ifname} via {gwaddr} ",
        "format-linked": "{ifname} (No IP) ",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}",
        "on-click": "nm-connection-editor",
        "on-click-right": "kitty -e nmtui"
    },
    
    "bluetooth": {
        "format": " {status}",
        "format-disabled": "",
        "format-off": "",
        "interval": 30,
        "on-click": "blueman-manager",
        "format-no-controller": ""
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
        "on-click": "pavucontrol",
        "on-click-right": "pactl set-sink-mute @DEFAULT_SINK@ toggle",
        "on-scroll-up": "pactl set-sink-volume @DEFAULT_SINK@ +1%",
        "on-scroll-down": "pactl set-sink-volume @DEFAULT_SINK@ -1%",
        "smooth-scrolling-threshold": 1
    },
    
    "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": {
            "activated": "",
            "deactivated": ""
        }
    },
    
    "custom/theme": {
        "tooltip": false,
        "format": "",
        "on-click": "~/.config/waybar/scripts/theme_switcher.sh"
    },
    
    "custom/wallpaper": {
        "tooltip": false,
        "format": "",
        "on-click": "~/.config/waybar/scripts/wallpaper_switcher.sh"
    },
    
    "custom/power": {
        "tooltip": false,
        "format": "⏻",
        "on-click": "wlogout"
    },
    
    "tray": {
        "icon-size": 16,
        "spacing": 10
    }
}
WAYBAR_EOF

# Create PREMIUM waybar CSS with advanced styling
cat > ~/.config/waybar/style.css << 'WAYBAR_CSS'
* {
    font-family: JetBrainsMono Nerd Font;
    font-size: 14px;
    font-weight: bold;
    border: none;
    border-radius: 0;
    min-height: 0;
}

window#waybar {
    background: linear-gradient(135deg, rgba(26, 27, 38, 0.85) 0%, rgba(36, 40, 59, 0.85) 100%);
    border-radius: 12px;
    color: #c0caf5;
    transition: all 0.3s cubic-bezier(0.55, 0.0, 0.28, 1.682);
    backdrop-filter: blur(20px);
    border: 2px solid rgba(122, 162, 247, 0.3);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

window#waybar.hidden {
    opacity: 0.2;
}

button {
    box-shadow: inset 0 -3px transparent;
    border: none;
    border-radius: 8px;
    transition: all 0.3s cubic-bezier(0.55, 0.0, 0.28, 1.682);
    min-width: 20px;
}

button:hover {
    background: rgba(116, 199, 236, 0.2);
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(122, 162, 247, 0.4);
}

#custom-logo {
    font-size: 18px;
    color: #7aa2f7;
    margin: 0 8px;
    padding: 0 12px;
    background: linear-gradient(45deg, rgba(122, 162, 247, 0.2), rgba(187, 154, 247, 0.2));
    border-radius: 12px;
    border: 1px solid rgba(122, 162, 247, 0.3);
}

#custom-logo:hover {
    background: linear-gradient(45deg, rgba(122, 162, 247, 0.4), rgba(187, 154, 247, 0.4));
    transform: rotate(360deg);
}

#workspaces {
    margin: 0 4px;
}

#workspaces button {
    padding: 5px 8px;
    background: transparent;
    color: #7aa2f7;
    margin: 0 2px;
    border-radius: 8px;
    transition: all 0.3s cubic-bezier(0.55, 0.0, 0.28, 1.682);
}

#workspaces button:hover {
    background: linear-gradient(45deg, rgba(116, 199, 236, 0.3), rgba(122, 162, 247, 0.3));
    transform: translateY(-2px) scale(1.05);
    box-shadow: 0 4px 12px rgba(122, 162, 247, 0.5);
}

#workspaces button.active {
    background: linear-gradient(45deg, #7aa2f7, #bb9af7);
    color: #1a1b26;
    transform: translateY(-1px) scale(1.1);
    box-shadow: 0 6px 16px rgba(122, 162, 247, 0.6);
}

#workspaces button.urgent {
    background: linear-gradient(45deg, #f7768e, #ff9e64);
    color: #1a1b26;
    animation: urgent 2s ease-in-out infinite;
}

@keyframes urgent {
    0%, 100% { 
        transform: scale(1);
        box-shadow: 0 2px 8px rgba(247, 118, 142, 0.4);
    }
    50% { 
        transform: scale(1.15);
        box-shadow: 0 6px 20px rgba(247, 118, 142, 0.8);
    }
}

#window {
    background: linear-gradient(45deg, rgba(158, 206, 106, 0.1), rgba(115, 218, 202, 0.1));
    color: #c0caf5;
    font-style: italic;
    padding: 6px 12px;
    margin: 0 4px;
    border-radius: 8px;
    border: 1px solid rgba(158, 206, 106, 0.2);
    transition: all 0.3s ease;
}

#window:hover {
    background: linear-gradient(45deg, rgba(158, 206, 106, 0.2), rgba(115, 218, 202, 0.2));
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(158, 206, 106, 0.3);
}

#submap {
    background: linear-gradient(45deg, rgba(224, 175, 104, 0.2), rgba(255, 158, 100, 0.2));
    color: #e0af68;
    padding: 6px 12px;
    margin: 0 4px;
    border-radius: 8px;
    border: 1px solid rgba(224, 175, 104, 0.3);
    animation: submap-glow 2s ease-in-out infinite;
}

@keyframes submap-glow {
    0%, 100% { box-shadow: 0 2px 8px rgba(224, 175, 104, 0.3); }
    50% { box-shadow: 0 4px 16px rgba(224, 175, 104, 0.6); }
}

#clock {
    background: linear-gradient(45deg, rgba(187, 154, 247, 0.1), rgba(122, 162, 247, 0.1));
    color: #bb9af7;
    font-weight: bold;
    padding: 6px 16px;
    margin: 0 4px;
    border-radius: 12px;
    border: 1px solid rgba(187, 154, 247, 0.2);
    transition: all 0.3s ease;
}

#clock:hover {
    background: linear-gradient(45deg, rgba(187, 154, 247, 0.2), rgba(122, 162, 247, 0.2));
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(187, 154, 247, 0.4);
}

#custom-weather {
    background: linear-gradient(45deg, rgba(125, 207, 255, 0.1), rgba(115, 218, 202, 0.1));
    color: #7dcfff;
    padding: 6px 12px;
    margin: 0 4px;
    border-radius: 8px;
    border: 1px solid rgba(125, 207, 255, 0.2);
}

#custom-notification {
    color: #f7768e;
    padding: 6px 12px;
    margin: 0 4px;
    border-radius: 8px;
    transition: all 0.3s ease;
}

#cpu {
    background: linear-gradient(45deg, rgba(187, 154, 247, 0.1), rgba(203, 166, 247, 0.1));
    color: #bb9af7;
    padding: 6px 12px;
    margin: 0 2px;
    border-radius: 8px;
    border: 1px solid rgba(187, 154, 247, 0.2);
    transition: all 0.3s ease;
}

#cpu:hover {
    background: linear-gradient(45deg, rgba(187, 154, 247, 0.2), rgba(203, 166, 247, 0.2));
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(187, 154, 247, 0.4);
}

#memory {
    background: linear-gradient(45deg, rgba(115, 218, 202, 0.1), rgba(125, 207, 255, 0.1));
    color: #73daca;
    padding: 6px 12px;
    margin: 0 2px;
    border-radius: 8px;
    border: 1px solid rgba(115, 218, 202, 0.2);
    transition: all 0.3s ease;
}

#memory:hover {
    background: linear-gradient(45deg, rgba(115, 218, 202, 0.2), rgba(125, 207, 255, 0.2));
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(115, 218, 202, 0.4);
}

#temperature {
    background: linear-gradient(45deg, rgba(255, 158, 100, 0.1), rgba(224, 175, 104, 0.1));
    color: #ff9e64;
    padding: 6px 12px;
    margin: 0 2px;
    border-radius: 8px;
    border: 1px solid rgba(255, 158, 100, 0.2);
}

#temperature.critical {
    background: linear-gradient(45deg, rgba(247, 118, 142, 0.3), rgba(255, 158, 100, 0.3));
    color: #1a1b26;
    animation: temperature-critical 1s ease-in-out infinite;
}

@keyframes temperature-critical {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.05); }
}

#backlight {
    background: linear-gradient(45deg, rgba(224, 175, 104, 0.1), rgba(255, 202, 104, 0.1));
    color: #e0af68;
    padding: 6px 12px;
    margin: 0 2px;
    border-radius: 8px;
    border: 1px solid rgba(224, 175, 104, 0.2);
}

#network {
    background: linear-gradient(45deg, rgba(125, 207, 255, 0.1), rgba(122, 162, 247, 0.1));
    color: #7dcfff;
    padding: 6px 12px;
    margin: 0 2px;
    border-radius: 8px;
    border: 1px solid rgba(125, 207, 255, 0.2);
    transition: all 0.3s ease;
}

#network:hover {
    background: linear-gradient(45deg, rgba(125, 207, 255, 0.2), rgba(122, 162, 247, 0.2));
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(125, 207, 255, 0.4);
}

#network.disconnected {
    background: linear-gradient(45deg, rgba(247, 118, 142, 0.2), rgba(255, 158, 100, 0.2));
    color: #f7768e;
}

#bluetooth {
    background: linear-gradient(45deg, rgba(122, 162, 247, 0.1), rgba(187, 154, 247, 0.1));
    color: #7aa2f7;
    padding: 6px 12px;
    margin: 0 2px;
    border-radius: 8px;
    border: 1px solid rgba(122, 162, 247, 0.2);
}

#bluetooth.off {
    background: linear-gradient(45deg, rgba(65, 72, 104, 0.2), rgba(36, 40, 59, 0.2));
    color: #565f89;
}

#pulseaudio {
    background: linear-gradient(45deg, rgba(224, 175, 104, 0.1), rgba(158, 206, 106, 0.1));
    color: #e0af68;
    padding: 6px 12px;
    margin: 0 2px;
    border-radius: 8px;
    border: 1px solid rgba(224, 175, 104, 0.2);
    transition: all 0.3s ease;
}

#pulseaudio:hover {
    background: linear-gradient(45deg, rgba(224, 175, 104, 0.2), rgba(158, 206, 106, 0.2));
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(224, 175, 104, 0.4);
}

#pulseaudio.muted {
    background: linear-gradient(45deg, rgba(247, 118, 142, 0.2), rgba(255, 158, 100, 0.2));
    color: #f7768e;
}

#battery {
    background: linear-gradient(45deg, rgba(158, 206, 106, 0.1), rgba(115, 218, 202, 0.1));
    color: #9ece6a;
    padding: 6px 12px;
    margin: 0 2px;
    border-radius: 8px;
    border: 1px solid rgba(158, 206, 106, 0.2);
    transition: all 0.3s ease;
}

#battery:hover {
    background: linear-gradient(45deg, rgba(158, 206, 106, 0.2), rgba(115, 218, 202, 0.2));
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(158, 206, 106, 0.4);
}

#battery.charging {
    background: linear-gradient(45deg, rgba(158, 206, 106, 0.2), rgba(125, 207, 255, 0.2));
    color: #9ece6a;
    animation: battery-charging 2s ease-in-out infinite;
}

@keyframes battery-charging {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.02); }
}

#battery.critical:not(.charging) {
    background: linear-gradient(45deg, rgba(247, 118, 142, 0.3), rgba(255, 158, 100, 0.3));
    color: #1a1b26;
    animation: battery-critical 0.5s linear infinite alternate;
}

@keyframes battery-critical {
    to {
        background: linear-gradient(45deg, rgba(255, 255, 255, 0.3), rgba(247, 118, 142, 0.3));
        color: #000000;
    }
}

#idle_inhibitor {
    background: linear-gradient(45deg, rgba(224, 175, 104, 0.1), rgba(255, 158, 100, 0.1));
    color: #e0af68;
    padding: 6px 12px;
    margin: 0 2px;
    border-radius: 8px;
    border: 1px solid rgba(224, 175, 104, 0.2);
}

#idle_inhibitor.activated {
    background: linear-gradient(45deg, rgba(247, 118, 142, 0.2), rgba(255, 158, 100, 0.2));
    color: #f7768e;
}

#custom-theme,
#custom-wallpaper,
#custom-power {
    color: #bb9af7;
    padding: 6px 12px;
    margin: 0 2px;
    border-radius: 8px;
    background: linear-gradient(45deg, rgba(187, 154, 247, 0.1), rgba(122, 162, 247, 0.1));
    border: 1px solid rgba(187, 154, 247, 0.2);
    transition: all 0.3s ease;
}

#custom-theme:hover,
#custom-wallpaper:hover {
    background: linear-gradient(45deg, rgba(187, 154, 247, 0.2), rgba(122, 162, 247, 0.2));
    transform: translateY(-1px) rotate(360deg);
    box-shadow: 0 2px 8px rgba(187, 154, 247, 0.4);
}

#custom-power:hover {
    background: linear-gradient(45deg, rgba(247, 118, 142, 0.2), rgba(255, 158, 100, 0.2));
    color: #f7768e;
    transform: translateY(-1px) scale(1.1);
    box-shadow: 0 2px 8px rgba(247, 118, 142, 0.4);
}

#tray {
    padding: 6px 12px;
    margin: 0 4px;
    border-radius: 8px;
    background: linear-gradient(45deg, rgba(65, 72, 104, 0.1), rgba(26, 27, 38, 0.1));
    border: 1px solid rgba(65, 72, 104, 0.2);
}

#tray > .passive {
    -gtk-icon-effect: dim;
}

#tray > .needs-attention {
    -gtk-icon-effect: highlight;
    background-color: #f7768e;
    border-radius: 6px;
}

/* Module state transitions */
tooltip {
    background: rgba(26, 27, 38, 0.95);
    color: #c0caf5;
    border-radius: 8px;
    border: 1px solid rgba(122, 162, 247, 0.3);
    backdrop-filter: blur(20px);
}

tooltip label {
    color: #c0caf5;
}
/* Responsive design */
@media (max-width: 1200px) {
    window#waybar {
        font-size: 12px;
    }
    
    #custom-weather,
    #custom-notification {
        display: none;
    }
}

@media (max-width: 800px) {
    #temperature,
    #bluetooth,
    #idle_inhibitor {
        display: none;
    }
}
WAYBAR_CSS

# Create waybar scripts directory and helper scripts
safe_run "mkdir -p ~/.config/waybar/scripts"

cat > ~/.config/waybar/scripts/theme_switcher.sh << 'THEME_SCRIPT'
#!/bin/bash
themes=("Tokyo Night" "Catppuccin" "Dracula" "Nord")
current_theme=$(cat ~/.config/waybar/current_theme 2>/dev/null || echo "Tokyo Night")

# Cycle to next theme
case $current_theme in
    "Tokyo Night") next_theme="Catppuccin" ;;
    "Catppuccin") next_theme="Dracula" ;;
    "Dracula") next_theme="Nord" ;;
    "Nord") next_theme="Tokyo Night" ;;
    *) next_theme="Tokyo Night" ;;
esac

echo $next_theme > ~/.config/waybar/current_theme
notify-send "Theme Changed" "Switched to $next_theme" -i preferences-desktop-theme
THEME_SCRIPT

cat > ~/.config/waybar/scripts/wallpaper_switcher.sh << 'WALLPAPER_SCRIPT'
#!/bin/bash
wallpaper_dir="$HOME/Pictures/Wallpapers"
if [ ! -d "$wallpaper_dir" ]; then
    mkdir -p "$wallpaper_dir"
fi

wallpapers=($(find "$wallpaper_dir" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \)))

if [ ${#wallpapers[@]} -eq 0 ]; then
    notify-send "No Wallpapers" "Add wallpapers to ~/Pictures/Wallpapers" -i image-x-generic
    exit 1
fi

random_wallpaper=${wallpapers[$RANDOM % ${#wallpapers[@]}]}
swww img "$random_wallpaper" --transition-type fade --transition-duration 2
notify-send "Wallpaper Changed" "$(basename "$random_wallpaper")" -i image-x-generic
WALLPAPER_SCRIPT

safe_run "chmod +x ~/.config/waybar/scripts/theme_switcher.sh"
safe_run "chmod +x ~/.config/waybar/scripts/wallpaper_switcher.sh"

success "✅ PREMIUM Waybar configuration created with advanced features"

# Create ULTIMATE terminal configurations
section "Creating ULTIMATE terminal configurations..."

# ULTIMATE Kitty config
safe_run "mkdir -p ~/.config/kitty"
cat > ~/.config/kitty/kitty.conf << 'KITTY_EOF'
# Font configuration
font_family JetBrainsMono Nerd Font
bold_font JetBrainsMono Nerd Font Bold
italic_font JetBrainsMono Nerd Font Italic
bold_italic_font JetBrainsMono Nerd Font Bold Italic
font_size 12.0
font_features JetBrainsMonoNF-Regular +cv01 +cv02 +cv03 +cv05 +cv07 +cv14

# Cursor configuration
cursor_shape block
cursor_beam_thickness 1.5
cursor_underline_thickness 2.0
cursor_blink_interval -1
cursor_stop_blinking_after 15.0

# Scrollback
scrollback_lines 10000
scrollback_pager less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER
scrollback_pager_history_size 0
scrollback_fill_enlarged_window false
wheel_scroll_multiplier 5.0
wheel_scroll_min_lines 1
touch_scroll_multiplier 1.0

# Mouse
mouse_hide_wait 3.0
url_color #7dcfff
url_style curly
open_url_with default
url_prefixes file ftp ftps gemini git gopher http https irc ircs kitty mailto news sftp ssh
detect_urls yes
copy_on_select no
strip_trailing_spaces never
select_by_word_characters @-./_~?&=%+#
click_interval -1.0
focus_follows_mouse no
pointer_shape_when_grabbed arrow
default_pointer_shape beam
pointer_shape_when_dragging beam

# Performance tuning
repaint_delay 10
input_delay 3
sync_to_monitor yes

# Terminal bell
enable_audio_bell no
visual_bell_duration 0.0
visual_bell_color none
window_alert_on_bell yes
bell_on_tab "🔔 "
command_on_bell none
bell_path none

# Window layout
remember_window_size yes
initial_window_width 640
initial_window_height 400
enabled_layouts *
window_resize_step_cells 2
window_resize_step_lines 2
window_border_width 0.5pt
draw_minimal_borders yes
window_margin_width 0
single_window_margin_width -1
window_padding_width 6
placement_strategy center
active_border_color #7aa2f7
inactive_border_color #414868
bell_border_color #f7768e
inactive_text_alpha 1.0

# Tab bar
tab_bar_edge bottom
tab_bar_margin_width 0.0
tab_bar_margin_height 0.0 0.0
tab_bar_style powerline
tab_bar_align left
tab_bar_min_tabs 2
tab_switch_strategy previous
tab_fade 0.25 0.5 0.75 1
tab_separator " ┇"
tab_powerline_style angled
tab_activity_symbol none
tab_title_template "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{title}"
active_tab_title_template none

# Color scheme (Tokyo Night)
foreground #c0caf5
background #1a1b26
selection_foreground #7aa2f7
selection_background #33467c

# Cursor colors
cursor #c0caf5
cursor_text_color #1a1b26

# URL underline color when hovering with mouse
url_color #73daca

# Kitty window border colors
active_border_color #7aa2f7
inactive_border_color #414868

# OS Window titlebar colors
wayland_titlebar_color system
macos_titlebar_color system

# Tab bar colors
active_tab_foreground #1a1b26
active_tab_background #7aa2f7
inactive_tab_foreground #c0caf5
inactive_tab_background #414868
tab_bar_background #1a1b26

# Colors for marks (marked text in the terminal)
mark1_foreground #1a1b26
mark1_background #7dcfff
mark2_foreground #1a1b26
mark2_background #bb9af7
mark3_foreground #1a1b26
mark3_background #9ece6a

# The 16 terminal colors

# black
color0 #15161e
color8 #414868

# red
color1 #f7768e
color9 #f7768e

# green
color2 #9ece6a
color10 #9ece6a

# yellow
color3 #e0af68
color11 #e0af68

# blue
color4 #7aa2f7
color12 #7aa2f7

# magenta
color5 #bb9af7
color13 #bb9af7

# cyan
color6 #7dcfff
color14 #7dcfff

# white
color7 #a9b1d6
color15 #c0caf5

# Advanced key mappings
map ctrl+c copy_to_clipboard
map ctrl+v paste_from_clipboard
map ctrl+shift+c send_text all \x03

# Window management
map ctrl+shift+enter new_window
map ctrl+shift+w close_window
map ctrl+shift+] next_window
map ctrl+shift+[ previous_window
map ctrl+shift+f move_window_forward
map ctrl+shift+b move_window_backward
map ctrl+shift+` move_window_to_top
map ctrl+shift+r start_resizing_window
map ctrl+shift+1 first_window
map ctrl+shift+2 second_window
map ctrl+shift+3 third_window
map ctrl+shift+4 fourth_window
map ctrl+shift+5 fifth_window
map ctrl+shift+6 sixth_window
map ctrl+shift+7 seventh_window
map ctrl+shift+8 eighth_window
map ctrl+shift+9 ninth_window
map ctrl+shift+0 tenth_window

# Tab management
map ctrl+shift+right next_tab
map ctrl+shift+left previous_tab
map ctrl+shift+t new_tab
map ctrl+shift+q close_tab
map shift+cmd+w close_os_window
map ctrl+shift+. move_tab_forward
map ctrl+shift+, move_tab_backward
map ctrl+shift+alt+t set_tab_title

# Layout management
map ctrl+shift+l next_layout
map ctrl+shift+alt+l last_used_layout

# Font sizes
map ctrl+shift+equal change_font_size all +2.0
map ctrl+shift+plus change_font_size all +2.0
map ctrl+shift+kp_add change_font_size all +2.0
map ctrl+shift+minus change_font_size all -2.0
map ctrl+shift+kp_subtract change_font_size all -2.0
map ctrl+shift+backspace change_font_size all 0

# Selection
map ctrl+shift+a select_all
map ctrl+shift+s paste_selection
map ctrl+shift+o pass_selection_to_program firefox

# Scrolling
map ctrl+shift+up scroll_line_up
map ctrl+shift+k scroll_line_up
map ctrl+shift+down scroll_line_down
map ctrl+shift+j scroll_line_down
map ctrl+shift+page_up scroll_page_up
map ctrl+shift+page_down scroll_page_down
map ctrl+shift+home scroll_home
map ctrl+shift+end scroll_end
map ctrl+shift+h show_scrollback
map ctrl+shift+g show_last_command_output

# Miscellaneous
map ctrl+shift+f11 toggle_fullscreen
map ctrl+shift+f10 toggle_maximized
map ctrl+shift+u kitten unicode_input
map ctrl+shift+f2 edit_config_file
map ctrl+shift+escape kitty_shell window

# Appearance settings
background_opacity 0.9
dynamic_background_opacity yes
background_blur 20
dim_opacity 0.75

# Shell integration
shell_integration enabled
allow_remote_control yes
listen_on unix:/tmp/kitty

# Advanced features
clipboard_control write-clipboard write-primary read-clipboard-ask read-primary-ask
clipboard_max_size 64
file_transfer_confirmation_bypass

# Startup session
startup_session none
allow_hyperlinks yes
shell_integration no-cursor
term xterm-kitty
KITTY_EOF

# ULTIMATE Alacritty config
safe_run "mkdir -p ~/.config/alacritty"
cat > ~/.config/alacritty/alacritty.yml << 'ALACRITTY_EOF'
# Configuration for Alacritty, the GPU enhanced terminal emulator.

# Window configuration
window:
  # Window dimensions (changes require restart)
  dimensions:
    columns: 0
    lines: 0

  # Window position (changes require restart)
  position:
    x: 0
    y: 0

  # Window padding (changes require restart)
  padding:
    x: 6
    y: 6

  # Spread additional padding evenly around the terminal content.
  dynamic_padding: false

  # Window decorations
  decorations: none

  # Opacity
  opacity: 0.9

  # Startup Mode (changes require restart)
  startup_mode: Windowed

  # Window title
  title: Alacritty

  # Allow terminal applications to change Alacritty's window title.
  dynamic_title: true

  # Window class (Linux/BSD only):
  class:
    instance: Alacritty
    general: Alacritty

  # GTK theme variant (Linux/BSD only)
  gtk_theme_variant: None

scrolling:
  # Maximum number of lines in the scrollback buffer.
  history: 10000

  # Scrolling distance multiplier.
  multiplier: 3

# Font configuration
font:
  # Normal (roman) font face
  normal:
    family: JetBrainsMono Nerd Font
    style: Regular

  # Bold font face
  bold:
    family: JetBrainsMono Nerd Font
    style: Bold

  # Italic font face
  italic:
    family: JetBrainsMono Nerd Font
    style: Italic

  # Bold italic font face
  bold_italic:
    family: JetBrainsMono Nerd Font
    style: Bold Italic

  # Point size
  size: 12.0

  # Offset is the extra space around each character. `offset.y` can be thought
  # of as modifying the line spacing, and `offset.x` as modifying the letter
  # spacing.
  offset:
    x: 0
    y: 0

  # Glyph offset determines the locations of the glyphs within their cells with
  # the default being at the bottom. Increasing `x` moves the glyph to the
  # right, increasing `y` moves the glyph upward.
  glyph_offset:
    x: 0
    y: 0

  # Thin stroke font rendering (macOS only)
  use_thin_strokes: true

# Colors (Tokyo Night)
colors:
  # Default colors
  primary:
    background: '#1a1b26'
    foreground: '#c0caf5'

  # Normal colors
  normal:
    black:   '#15161e'
    red:     '#f7768e'
    green:   '#9ece6a'
    yellow:  '#e0af68'
    blue:    '#7aa2f7'
    magenta: '#bb9af7'
    cyan:    '#7dcfff'
    white:   '#a9b1d6'

  # Bright colors
  bright:
    black:   '#414868'
    red:     '#f7768e'
    green:   '#9ece6a'
    yellow:  '#e0af68'
    blue:    '#7aa2f7'
    magenta: '#bb9af7'
    cyan:    '#7dcfff'
    white:   '#c0caf5'

  # Indexed Colors
  indexed_colors:
    - { index: 16, color: '#ff9e64' }
    - { index: 17, color: '#db4b4b' }

  # Selection colors
  selection:
    text: CellForeground
    background: '#33467c'

  # Search colors
  search:
    matches:
      foreground: '#1a1b26'
      background: '#73daca'
    focused_match:
      foreground: '#1a1b26'
      background: '#ff9e64'

  # Cursor colors
  cursor:
    text: CellBackground
    cursor: CellForeground

  # Vi mode cursor colors
  vi_mode_cursor:
    text: CellBackground
    cursor: CellForeground

  # Line indicator colors
  line_indicator:
    foreground: None
    background: None

  # Footer bar colors
  footer_bar:
    background: '#1a1b26'
    foreground: '#c0caf5'

  # Hints
  hints:
    start:
      foreground: '#1a1b26'
      background: '#e0af68'
    end:
      foreground: '#1a1b26'
      background: '#73daca'

# Bell configuration
bell:
  animation: EaseOutExpo
  duration: 0
  color: '#ffffff'
  command: None

# Background opacity
background_opacity: 0.9

# Mouse bindings
mouse_bindings:
  - { mouse: Right, action: PasteSelection }

mouse:
  # Click settings
  double_click: { threshold: 300 }
  triple_click: { threshold: 300 }

  # If this is `true`, the cursor is temporarily hidden when typing.
  hide_when_typing: false

  # Regex hints
  hints:
    launcher:
      program: xdg-open
      args: []
    modifiers: None

# Selection configuration
selection:
  # This string contains all characters that are used as separators for
  # "semantic words" in Alacritty.
  semantic_escape_chars: ",│`|:\"' ()[]{}<>\t"

  # When set to `true`, selected text will be copied to the primary clipboard.
  save_to_clipboard: false

cursor:
  # Cursor style
  style:
    # Cursor shape
    shape: Block

    # Cursor blinking state
    blinking: Never

  # Vi mode cursor style
  vi_mode_style: None

  # Cursor blinking interval in milliseconds.
  blink_interval: 750

  # If this is `true`, the cursor will be rendered as a hollow box when the
  # window is not focused.
  unfocused_hollow: true

  # Thickness of the cursor relative to the cell width as floating point number
  # from `0.0` to `1.0`.
  thickness: 0.15

# Live config reload (changes require restart)
live_config_reload: true

# Shell
shell:
  program: /bin/zsh

# Startup directory
working_directory: None

# WinPTY backend (Windows only)
winpty_backend: false

# Send ESC (\x1b) before characters when alt is pressed.
alt_send_esc: true

# Offer IPC using `alacritty msg`
ipc_socket: true

# Key bindings
key_bindings:
  # Copy/Paste
  - { key: C, mods: Control, action: Copy }
  - { key: V, mods: Control, action: Paste }
  - { key: C, mods: Control|Shift, chars: "\x03" }

  # Search
  - { key: F, mods: Control, action: SearchForward }
  - { key: B, mods: Control, action: SearchBackward }

  # Font size
  - { key: Plus, mods: Control, action: IncreaseFontSize }
  - { key: Minus, mods: Control, action: DecreaseFontSize }
  - { key: Key0, mods: Control, action: ResetFontSize }

  # Window management
  - { key: Return, mods: Control|Shift, action: SpawnNewInstance }
  - { key: N, mods: Control|Shift, action: SpawnNewInstance }

  # Scrolling
  - { key: PageUp, mods: Shift, action: ScrollPageUp, mode: ~Alt }
  - { key: PageDown, mods: Shift, action: ScrollPageDown, mode: ~Alt }
  - { key: Home, mods: Shift, action: ScrollToTop, mode: ~Alt }
  - { key: End, mods: Shift, action: ScrollToBottom, mode: ~Alt }

  # Vi Mode
  - { key: Space, mods: Shift|Control, action: ToggleViMode }
  - { key: Space, mods: Shift|Control, action: SearchForward, mode: Vi|~Search }
  - { key: Escape, action: ClearLogNotice, mode: ~Vi|~Search }
  - { key: I, action: ToggleViMode, mode: Vi|~Search }
  - { key: I, action: ScrollToBottom, mode: Vi|~Search }
  - { key: C, mods: Control, action: ToggleViMode, mode: Vi|~Search }
  - { key: Y, mods: Control, action: ScrollLineUp, mode: Vi|~Search }
  - { key: E, mods: Control, action: ScrollLineDown, mode: Vi|~Search }
  - { key: G, action: ScrollToTop, mode: Vi|~Search }
  - { key: G, mods: Shift, action: ScrollToBottom, mode: Vi|~Search }
  - { key: B, mods: Control, action: ScrollPageUp, mode: Vi|~Search }
  - { key: F, mods: Control, action: ScrollPageDown, mode: Vi|~Search }
  - { key: U, mods: Control, action: ScrollHalfPageUp, mode: Vi|~Search }
  - { key: D, mods: Control, action: ScrollHalfPageDown, mode: Vi|~Search }
  - { key: Y, action: Copy, mode: Vi|~Search }
  - { key: Y, action: ClearSelection, mode: Vi|~Search }
  - { key: Copy, action: ClearSelection, mode: Vi|~Search }
  - { key: V, action: ToggleNormalSelection, mode: Vi|~Search }
  - { key: V, mods: Shift, action: ToggleLineSelection, mode: Vi|~Search }
  - { key: V, mods: Control, action: ToggleBlockSelection, mode: Vi|~Search }
  - { key: V, mods: Alt, action: ToggleSemanticSelection, mode: Vi|~Search }
  - { key: Return, action: Open, mode: Vi|~Search }
  - { key: K, action: Up, mode: Vi|~Search }
  - { key: J, action: Down, mode: Vi|~Search }
  - { key: H, action: Left, mode: Vi|~Search }
  - { key: L, action: Right, mode: Vi|~Search }
  - { key: Up, action: Up, mode: Vi|~Search }
  - { key: Down, action: Down, mode: Vi|~Search }
  - { key: Left, action: Left, mode: Vi|~Search }
  - { key: Right, action: Right, mode: Vi|~Search }
  - { key: Key0, action: First, mode: Vi|~Search }
  - { key: Key4, mods: Shift, action: Last, mode: Vi|~Search }
  - { key: Key6, mods: Shift, action: FirstOccupied, mode: Vi|~Search }
  - { key: H, mods: Shift, action: High, mode: Vi|~Search }
  - { key: M, mods: Shift, action: Middle, mode: Vi|~Search }
  - { key: L, mods: Shift, action: Low, mode: Vi|~Search }
  - { key: B, action: SemanticLeft, mode: Vi|~Search }
  - { key: W, action: SemanticRight, mode: Vi|~Search }
  - { key: E, action: SemanticRightEnd, mode: Vi|~Search }
  - { key: B, mods: Shift, action: WordLeft, mode: Vi|~Search }
  - { key: W, mods: Shift, action: WordRight, mode: Vi|~Search }
  - { key: E, mods: Shift, action: WordRightEnd, mode: Vi|~Search }
  - { key: Key5, mods: Shift, action: Bracket, mode: Vi|~Search }
  - { key: Slash, action: SearchForward, mode: Vi|~Search }
  - { key: Slash, mods: Shift, action: SearchBackward, mode: Vi|~Search }
  - { key: N, action: SearchNext, mode: Vi|~Search }
  - { key: N, mods: Shift, action: SearchPrevious, mode: Vi|~Search }

debug:
  render_timer: false
  persistent_logging: false
  log_level: Warn
  print_events: false
ALACRITTY_EOF

# ULTIMATE WezTerm config
safe_run "mkdir -p ~/.config/wezterm"
cat > ~/.config/wezterm/wezterm.lua << 'WEZTERM_EOF'
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font configuration
config.font = wezterm.font_with_fallback {
  'JetBrainsMono Nerd Font',
  'Fira Code',
  'Cascadia Code',
}
config.font_size = 12.0
config.line_height = 1.1
config.cell_width = 1.0
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- Appearance
config.color_scheme = 'Tokyo Night'
config.window_background_opacity = 0.9
config.text_background_opacity = 1.0

-- Custom Tokyo Night colors
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
    '#15161e', -- black
    '#f7768e', -- red
    '#9ece6a', -- green
    '#e0af68', -- yellow
    '#7aa2f7', -- blue
    '#bb9af7', -- magenta
    '#7dcfff', -- cyan
    '#a9b1d6', -- white
  },
  
  brights = {
    '#414868', -- bright black
    '#f7768e', -- bright red
    '#9ece6a', -- bright green
    '#e0af68', -- bright yellow
    '#7aa2f7', -- bright blue
    '#bb9af7', -- bright magenta
    '#7dcfff', -- bright cyan
    '#c0caf5', -- bright white
  },
  
  indexed = {
    [16] = '#ff9e64',
    [17] = '#db4b4b',
  },
  
  tab_bar = {
    background = '#1a1b26',
    active_tab = {
      bg_color = '#7aa2f7',
      fg_color = '#1a1b26',
      intensity = 'Bold',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
    inactive_tab = {
      bg_color = '#414868',
      fg_color = '#c0caf5',
      intensity = 'Normal',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
    inactive_tab_hover = {
      bg_color = '#565f89',
      fg_color = '#c0caf5',
      intensity = 'Normal',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
    new_tab = {
      bg_color = '#1a1b26',
      fg_color = '#7aa2f7',
      intensity = 'Bold',
      underline = 'None',
      italic = false,
      strikethrough = false,
    },
  },
}

-- Window configuration
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

-- Tab bar
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.show_tab_index_in_tab_bar = false
config.tab_max_width = 32

-- Scrollback
config.scrollback_lines = 10000

-- Performance
config.max_fps = 60
config.animation_fps = 1
config.cursor_blink_rate = 800
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- Advanced features
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_resize_increments = true
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 150,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 150,
}

-- Key bindings
config.disable_default_key_bindings = false
config.keys = {
  -- Copy/paste
  { key = 'c', mods = 'CTRL', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.SendKey { key = 'c', mods = 'CTRL' } },
  
  -- Font size
  { key = '=', mods = 'CTRL', action = wezterm.action.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = wezterm.action.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = wezterm.action.ResetFontSize },
  
  -- Window/Tab management
  { key = 'Enter', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnWindow },
  { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = true } },
  
  -- Tab navigation
  { key = 'Tab', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
  
  -- Pane management
  { key = '"', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = '%', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Down' },
  
  -- Search
  { key = 'f', mods = 'CTRL|SHIFT', action = wezterm.action.Search { CaseSensitiveString = '' } },
  
  -- Quick select mode
  { key = ' ', mods = 'CTRL|SHIFT', action = wezterm.action.QuickSelect },
-- Copy mode (vim-like)
  { key = 'x', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateCopyMode },
  
  -- Scrolling
  { key = 'PageUp', mods = 'SHIFT', action = wezterm.action.ScrollByPage(-1) },
  { key = 'PageDown', mods = 'SHIFT', action = wezterm.action.ScrollByPage(1) },
  { key = 'Home', mods = 'SHIFT', action = wezterm.action.ScrollToTop },
  { key = 'End', mods = 'SHIFT', action = wezterm.action.ScrollToBottom },
}

-- Mouse bindings
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
  {
    event = { Up = { streak = 1, button = 'Right' } },
    mods = 'CTRL',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
}

-- Hyperlinks
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Additional hyperlink rules
table.insert(config.hyperlink_rules, {
  regex = [[\b\w+://(?:[\w.-]+)\.[a-z]{2,15}\S*\b]],
  format = '$0',
})

-- SSH domain configuration
config.ssh_domains = {}

-- Unix domain configuration
config.unix_domains = {}

-- WSL domain configuration (for Windows)
config.wsl_domains = {}

return config
WEZTERM_EOF

success "✅ ULTIMATE terminal configurations created"

# Set up ENHANCED shell environment
section "Setting up ENHANCED shell environment..."
if [[ ! -f ~/.zshrc ]]; then
    cat > ~/.zshrc << 'ZSHRC_EOF'
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Starship prompt (premium shell prompt)
eval "$(starship init zsh)"

# Environment variables
export PATH=$PATH:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=firefox
export TERMINAL=kitty
export TERM=xterm-256color
export COLORTERM=truecolor

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Development environment
export GOPATH="$HOME/go"
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"

# History configuration
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt appendhistory
setopt sharehistory
setopt incappendhistory
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_find_no_dups
setopt hist_save_no_dups

# Auto-completion
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'

# Directory navigation
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_minus

# General aliases
alias ll="ls -la --color=auto"
alias la="ls -A --color=auto"
alias l="ls -CF --color=auto"
alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"
alias cls="clear"
alias reload="source ~/.zshrc"
alias zshconfig="$EDITOR ~/.zshrc"

# Enhanced directory listing
alias lsa="ls -lah --color=auto"
alias lsl="ls -lh --color=auto"
alias lst="ls -lth --color=auto"
alias lss="ls -lSh --color=auto"

# Git aliases
alias gs="git status"
alias ga="git add"
alias gaa="git add ."
alias gc="git commit"
alias gcm="git commit -m"
alias gca="git commit -am"
alias gp="git push"
alias gpl="git pull"
alias gl="git log --oneline"
alias glo="git log --oneline --graph"
alias gb="git branch"
alias gco="git checkout"
alias gd="git diff"
alias gds="git diff --staged"
alias gr="git remote"
alias gf="git fetch"

# Development aliases
alias py="python"
alias py3="python3"
alias pip="pip3"
alias nv="nvim"
alias vim="nvim"
alias code="code"
alias cursor="cursor"

# System aliases
alias sysinfo="fastfetch"
alias cpu="btop"
alias df="df -h"
alias du="du -ch"
alias free="free -h"
alias ps="ps aux"
alias top="btop"
alias htop="btop"

# Hyprland specific aliases
alias hypr-reload="hyprctl reload"
alias hypr-logs="journalctl -f -u hyprland"
alias hypr-config="$EDITOR ~/.config/hypr/hyprland.conf"
alias waybar-config="$EDITOR ~/.config/waybar/config"
alias waybar-reload="killall waybar && waybar &"

# Package management aliases
alias pacin="sudo pacman -S"
alias pacup="sudo pacman -Syu"
alias pacsearch="pacman -Ss"
alias pacinfo="pacman -Si"
alias pacclean="sudo pacman -Sc"
alias paruup="paru -Syu"
alias paruins="paru -S"

# Network aliases
alias ping="ping -c 5"
alias wget="wget -c"
alias curl="curl -L"

# Archive aliases
alias mktar="tar -cvf"
alias mkbz2="tar -cvjf"
alias mkgz="tar -cvzf"
alias untar="tar -xvf"
alias unbz2="tar -xvjf"
alias ungz="tar -xvzf"

# Safety aliases
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias ln="ln -i"

# Functions
mkcd() { mkdir -p "$1" && cd "$1"; }
backup() { cp "$1"{,.bak}; }
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Load plugins if available
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
fi

if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Key bindings
bindkey -e  # Emacs mode
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Welcome message
if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi

# Display random quote or tip
echo ""
echo "💡 Pro tip: Use 'Super + R' to open the app launcher!"
echo "🎨 Change wallpapers with the waybar wallpaper button"
echo "⚡ Press 'Super + L' to lock your screen"
echo ""
ZSHRC_EOF
fi

# Install enhanced ZSH plugins
safe_pacman zsh-autosuggestions zsh-syntax-highlighting

# Create PREMIUM rofi configuration
section "Creating PREMIUM rofi configuration..."
safe_run "mkdir -p ~/.config/rofi"
cat > ~/.config/rofi/config.rasi << 'ROFI_EOF'
configuration {
    modi: "drun,run,window,ssh,filebrowser";
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
    display-filebrowser: "   Files";
    sidebar-mode: true;
    kb-row-up: "Up,Control+k,Shift+Tab,Shift+ISO_Left_Tab";
    kb-row-down: "Down,Control+j";
    kb-accept-entry: "Control+z,Control+y,Return,KP_Enter";
    kb-remove-to-eol: "Control+Shift+e";
    kb-mode-next: "Shift+Right,Control+Tab";
    kb-mode-previous: "Shift+Left,Control+Shift+Tab";
    kb-remove-char-back: "BackSpace";
    kb-row-select: "Control+space";
    kb-screenshot: "Alt+S";
    kb-ellipsize: "Alt+period";
    timeout {
        action: "kb-cancel";
        delay:  0;
    }
    filebrowser {
        directories-first: true;
        sorting-method:    "name";
    }
}

@theme "~/.config/rofi/launcher.rasi"
ROFI_EOF

# Create PREMIUM rofi theme
cat > ~/.config/rofi/launcher.rasi << 'ROFI_THEME'
* {
    background-color: rgba(26, 27, 38, 0.95);
    border-color: #7aa2f7;
    text-color: #c0caf5;
    spacing: 0;
    width: 600px;
    font: "JetBrainsMono Nerd Font 12";
}

window {
    background-color: @background-color;
    border: 3px;
    border-radius: 15px;
    border-color: @border-color;
    padding: 20px;
    transparency: "real";
    location: center;
    anchor: center;
    fullscreen: false;
    width: 600px;
    x-offset: 0px;
    y-offset: 0px;
}

mainbox {
    background-color: transparent;
    children: [ inputbar, message, listview, mode-switcher ];
    spacing: 15px;
    padding: 0px;
}

inputbar {
    background-color: rgba(65, 72, 104, 0.2);
    text-color: @text-color;
    border: 2px 2px 2px 2px;
    border-color: @border-color;
    border-radius: 10px;
    padding: 12px;
    spacing: 10px;
    children: [ prompt, textbox-prompt-colon, entry, case-indicator ];
}

prompt {
    background-color: transparent;
    text-color: #7aa2f7;
    font: "JetBrainsMono Nerd Font Bold 14";
    margin: 0px;
    padding: 0px;
}

textbox-prompt-colon {
    background-color: transparent;
    text-color: #bb9af7;
    expand: false;
    str: ":";
    margin: 0px 5px 0px 0px;
}

entry {
    background-color: transparent;
    text-color: @text-color;
    placeholder-color: #565f89;
    expand: true;
    horizontal-align: 0;
    placeholder: "Search applications...";
    blink: true;
    margin: 0px;
    padding: 0px;
}

case-indicator {
    background-color: transparent;
    text-color: #e0af68;
    spacing: 0;
    margin: 0px;
    padding: 0px;
}

listview {
    background-color: transparent;
    spacing: 2px;
    cycle: false;
    dynamic: true;
    scrollbar: true;
    layout: vertical;
    reverse: false;
    fixed-height: true;
    fixed-columns: true;
    border: 0px;
    border-radius: 8px;
    margin: 0px;
    padding: 0px;
}

scrollbar {
    background-color: rgba(65, 72, 104, 0.3);
    handle-color: #7aa2f7;
    handle-width: 8px;
    border: 0;
    border-radius: 4px;
    margin: 0 0 0 5px;
    padding: 0;
}

element {
    background-color: transparent;
    text-color: @text-color;
    orientation: horizontal;
    border-radius: 8px;
    spacing: 8px;
    margin: 0px;
    padding: 12px;
    border: 0px;
    cursor: pointer;
}

element normal.normal {
    background-color: transparent;
    text-color: @text-color;
}

element normal.urgent {
    background-color: rgba(247, 118, 142, 0.2);
    text-color: #f7768e;
}

element normal.active {
    background-color: rgba(158, 206, 106, 0.2);
    text-color: #9ece6a;
}

element selected.normal {
    background-color: linear-gradient(45deg, #7aa2f7, #bb9af7);
    text-color: #1a1b26;
    border-radius: 8px;
}

element selected.urgent {
    background-color: linear-gradient(45deg, #f7768e, #ff9e64);
    text-color: #1a1b26;
}

element selected.active {
    background-color: linear-gradient(45deg, #9ece6a, #73daca);
    text-color: #1a1b26;
}

element alternate.normal {
    background-color: rgba(65, 72, 104, 0.1);
    text-color: @text-color;
}

element alternate.urgent {
    background-color: rgba(247, 118, 142, 0.15);
    text-color: #f7768e;
}

element alternate.active {
    background-color: rgba(158, 206, 106, 0.15);
    text-color: #9ece6a;
}

element-icon {
    background-color: transparent;
    text-color: inherit;
    size: 32px;
    margin: 0px 8px 0px 0px;
    cursor: inherit;
}

element-text {
    background-color: transparent;
    text-color: inherit;
    highlight: inherit;
    cursor: inherit;
    vertical-align: 0.5;
    horizontal-align: 0.0;
}

mode-switcher {
    background-color: rgba(65, 72, 104, 0.2);
    text-color: @text-color;
    border: 2px;
    border-color: @border-color;
    border-radius: 8px;
    padding: 8px;
    spacing: 5px;
}

button {
    background-color: transparent;
    text-color: #7aa2f7;
    border: 0px;
    border-radius: 6px;
    padding: 8px 12px;
    cursor: pointer;
    horizontal-align: 0.5;
}

button selected {
    background-color: #7aa2f7;
    text-color: #1a1b26;
    border: 0px;
    border-radius: 6px;
}

message {
    background-color: rgba(224, 175, 104, 0.2);
    text-color: #e0af68;
    border: 2px;
    border-color: #e0af68;
    border-radius: 8px;
    padding: 10px;
    margin: 0px;
}

textbox {
    background-color: transparent;
    text-color: inherit;
    vertical-align: 0.5;
    horizontal-align: 0.0;
    highlight: none;
    blink: true;
    markup: true;
}

error-message {
    background-color: rgba(247, 118, 142, 0.2);
    text-color: #f7768e;
    border: 2px;
    border-color: #f7768e;
    border-radius: 8px;
    padding: 15px;
    margin: 0px;
}
ROFI_THEME

success "✅ PREMIUM rofi configuration created"

# Create ENHANCED dunst notification configuration
section "Creating ENHANCED dunst notification configuration..."
safe_run "mkdir -p ~/.config/dunst"
cat > ~/.config/dunst/dunstrc << 'DUNST_EOF'
[global]
    monitor = 0
    follow = none
    
    # Geometry
    width = (300, 400)
    height = 350
    origin = top-right
    offset = 15x50
    scale = 0
    notification_limit = 5
    
    # Progress bar
    progress_bar = true
    progress_bar_height = 14
    progress_bar_frame_width = 2
    progress_bar_min_width = 200
    progress_bar_max_width = 350
    progress_bar_corner_radius = 6
    progress_bar_corners = all
    
    # General
    indicate_hidden = yes
    transparency = 10
    notification_height = 0
    separator_height = 3
    padding = 15
    horizontal_padding = 15
    text_icon_padding = 10
    frame_width = 3
    frame_color = "#7aa2f7"
    gap_size = 5
    separator_color = frame
    sort = yes
    
    # Text
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
    
    # Icons
    enable_recursive_icon_lookup = true
    icon_theme = Papirus-Dark
    icon_position = left
    min_icon_size = 32
    max_icon_size = 64
    icon_path = /usr/share/icons/Papirus/48x48/status/:/usr/share/icons/Papirus/48x48/devices/:/usr/share/icons/Papirus/48x48/apps/:/usr/share/icons/hicolor/48x48/apps/
    
    # History
    sticky_history = yes
    history_length = 50
    
    # Misc/Advanced
    dmenu = /usr/bin/rofi -dmenu -p "dunst:"
    browser = /usr/bin/firefox
    always_run_script = true
    title = Dunst
    class = Dunst
    corner_radius = 12
    corners = all
    ignore_dbusclose = false
    force_xwayland = false
    force_xinerama = false
    
    # Mouse
    mouse_left_click = do_action, close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all
    
    # Legacy
    notification_timeout = 0

[experimental]
    per_monitor_dpi = false

[urgency_low]
    background = "#1a1b26"
    foreground = "#c0caf5"
    frame_color = "#414868"
    timeout = 8
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

# Application specific rules
[spotify]
    appname = "Spotify"
    frame_color = "#1db954"
    timeout = 5

[discord]
    appname = "Discord"
    frame_color = "#5865f2"
    timeout = 8

[firefox]
    appname = "Firefox"
    frame_color = "#ff7139"
    timeout = 6

[code]
    appname = "Visual Studio Code"
    frame_color = "#007acc"
    timeout = 5

# Shortcuts
[shortcuts]
    close = ctrl+space
    close_all = ctrl+shift+space
    history = ctrl+grave
    context = ctrl+shift+period
DUNST_EOF

success "✅ ENHANCED dunst notification configuration created"

# Create ULTIMATE hyprlock configuration
section "Creating ULTIMATE hyprlock configuration..."
cat > ~/.config/hypr/hyprlock.conf << 'HYPRLOCK_EOF'
general {
    disable_loading_bar = false
    grace = 300
    hide_cursor = true
    no_fade_in = false
    no_fade_out = false
    ignore_empty_input = false
    immediate_render = false
    pam_module = hyprlock
    text_trim = true
}

background {
    monitor =
    path = screenshot
    blur_passes = 4
    blur_size = 10
    noise = 0.0117
    contrast = 0.8916
    brightness = 0.8172
    vibrancy = 0.1696
    vibrancy_darkness = 0.0
}

# Clock
label {
    monitor =
    text = cmd[update:1000] echo "$TIME"
    color = rgb(c0caf5)
    font_size = 90
    font_family = JetBrainsMono Nerd Font Bold
    position = 0, 80
    halign = center
    valign = center
    shadow_passes = 5
    shadow_size = 10
    shadow_color = rgb(1a1b26)
    shadow_boost = 1.2
}

# Date
label {
    monitor =
    text = cmd[update:43200000] echo "$(date +"%A, %B %d")"
    color = rgb(c0caf5)
    font_size = 25
    font_family = JetBrainsMono Nerd Font
    position = 0, -30
    halign = center
    valign = center
    shadow_passes = 5
    shadow_size = 10
}

# User
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

# User avatar
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
    shadow_passes = 3
    shadow_size = 8
}

# Input field
input-field {
    monitor =
    size = 350, 70
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
    placeholder_text = <i>Enter Password...</i>
    hide_input = false
    rounding = 12
    check_color = rgb(9ece6a)
    fail_color = rgb(f7768e)
    fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
    fail_timeout = 2000
    fail_transition = 300
    capslock_color = -1
    numlock_color = -1
    bothlock_color = -1
    invert_numlock = false
    swap_font_color = false
    position = 0, -20
    halign = center
    valign = center
    shadow_passes = 2
    shadow_size = 4
}

# System info
label {
    monitor =
    text = cmd[update:30000] echo "$(uptime -p | sed 's/up /Uptime: /')"
    color = rgb(7dcfff)
    font_size = 12
    font_family = JetBrainsMono Nerd Font
    position = 30, 30
    halign = left
    valign = bottom
}

# Battery (if available)
label {
    monitor =
    text = cmd[update:5000] echo "$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1 | sed 's/$/%/' | sed 's/^/Battery: /' || echo '')"
    color = rgb(9ece6a)
    font_size = 12
    font_family = JetBrainsMono Nerd Font
    position = 30, 60
    halign = left
    valign = bottom
}

# Weather (requires wttr.in)
label {
    monitor =
    text = cmd[update:300000] curl -s 'wttr.in/?format=%C+%t' 2>/dev/null || echo ""
    color = rgb(e0af68)
    font_size = 14
    font_family = JetBrainsMono Nerd Font
    position = -30, 30
    halign = right
    valign = bottom
}
HYPRLOCK_EOF

# Create hypridle configuration
cat > ~/.config/hypr/hypridle.conf << 'HYPRIDLE_EOF'
general {
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
    ignore_dbus_inhibit = false
    ignore_systemd_inhibit = false
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

success "✅ ULTIMATE hyprlock and hypridle configurations created"

# Create PREMIUM wlogout configuration
safe_run "mkdir -p ~/.config/wlogout"
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
    box-shadow: none;
}

window {
    background-color: rgba(26, 27, 38, 0.9);
    backdrop-filter: blur(20px);
}

button {
    color: #c0caf5;
    background-color: rgba(122, 162, 247, 0.1);
    border-style: solid;
    border-width: 3px;
    background-repeat: no-repeat;
    background-position: center;
    background-size: 25%;
    /* Responsive design */
@media (max-width: 1200px) {
    window#waybar {
        font-size: 12px;
    }
    
    #custom-weather,
    #custom-notification {
        display: none;
    }
}

@media (max-width: 800px) {
    #temperature,
    #bluetooth,
    #idle_inhibitor {
        display: none;
    }
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