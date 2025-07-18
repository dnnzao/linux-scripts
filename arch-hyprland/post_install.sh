#!/bin/bash
#===============================================================================
# Arch Linux Post Installation - Hyprland Setup (FIXED)
# Author: Dênio Barbosa Júnior
# Description: Installs Hyprland, applications, and configurations
#===============================================================================

# Remove set -e to allow graceful error handling
# set -e

# Colors and logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
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

# Install essential Wayland and graphics packages first
section "Installing essential Wayland and graphics packages..."
sudo pacman -S --needed --noconfirm \
    wayland wayland-protocols \
    xorg-xwayland \
    mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon \
    vulkan-intel lib32-vulkan-intel \
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
sudo pacman -S --needed --noconfirm papirus-icon-theme arc-theme lxappearance qt5ct || warn "Some theme packages not available"

# Install development tools
section "Installing development tools..."
sudo pacman -S --needed --noconfirm \
    go rust python python-pip \
    postgresql postgresql-contrib \
    docker docker-compose \
    neovim vim code || warn "Some development tools failed to install"

# Install Hyprland ecosystem with better error handling
section "Installing Hyprland ecosystem..."

# Install stable Hyprland first as fallback
sudo pacman -S --needed --noconfirm hyprland || warn "Failed to install stable Hyprland"

# Try to install git versions with paru
paru -S --needed --noconfirm --skipreview hyprland-git || {
    warn "Failed to install hyprland-git, using stable version"
    sudo pacman -S --needed --noconfirm hyprland
}

# Install other Hyprland components
paru -S --needed --noconfirm --skipreview \
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
sudo pacman -S --needed --noconfirm kitty alacritty || warn "Failed to install some terminals"
paru -S --needed --noconfirm --skipreview wezterm || warn "Failed to install wezterm"

# Install additional tools
sudo pacman -S --needed --noconfirm cava || warn "Failed to install cava"

# Install gaming tools
section "Installing gaming tools..."
sudo pacman -S --needed --noconfirm \
    steam wine wine-gecko wine-mono \
    lutris gamemode lib32-gamemode || warn "Some gaming tools failed to install"

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

# Install display manager
section "Installing display manager..."
paru -S --needed --noconfirm --skipreview greetd-tuigreet || {
    warn "Failed to install greetd-tuigreet, installing gdm as fallback"
    sudo pacman -S --needed --noconfirm gdm
    sudo systemctl enable gdm
}

if command -v greetd &> /dev/null; then
    sudo systemctl enable greetd
fi

# Enable services
section "Enabling services..."
sudo systemctl enable docker || warn "Failed to enable docker"
sudo systemctl enable postgresql || warn "Failed to enable postgresql" 
sudo systemctl enable bluetooth || warn "Bluetooth not available (normal in VM)"
sudo systemctl start bluetooth || warn "Could not start bluetooth (normal in VM)"

# Add user to groups
sudo usermod -aG docker,input,video $USER

# Create enhanced Hyprland config
section "Creating Hyprland configuration..."
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/hyprland.conf << 'HYPR_EOF'
# Monitor configuration
monitor=,preferred,auto,1

# Environment variables
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt5ct
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
env = WLR_NO_HARDWARE_CURSORS,1
env = WLR_RENDERER_ALLOW_SOFTWARE,1

# Autostart
exec-once = waybar
exec-once = dunst
exec-once = swww init || swww-daemon
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# Input configuration
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

# General settings
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(7aa2f7ff)
    col.inactive_border = rgba(414868aa)
    layout = dwindle
    allow_tearing = false
    resize_on_border = true
}

# Decoration (reduced for VM)
decoration {
    rounding = 8
    blur {
        enabled = false
        size = 3
        passes = 1
    }
    drop_shadow = false
    active_opacity = 1.0
    inactive_opacity = 0.9
    fullscreen_opacity = 1.0
}

# Animations (reduced for VM)
animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 4, myBezier
    animation = windowsOut, 1, 4, default, popin 80%
    animation = border, 1, 5, default
    animation = fade, 1, 4, default
    animation = workspaces, 1, 3, default
}

# Layout
dwindle {
    pseudotile = true
    preserve_split = true
}

# Window rules
windowrule = float,^(pavucontrol)$
windowrule = float,^(lxappearance)$
windowrule = float,^(qt5ct)$

# Key bindings
$mainMod = SUPER

# Application shortcuts
bind = $mainMod, Return, exec, kitty
bind = $mainMod SHIFT, Return, exec, alacritty
bind = $mainMod, C, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, rofi -show drun || wofi --show drun
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,
bind = $mainMod, F, fullscreen,

# Move focus with vim keys
bind = $mainMod, h, movefocus, l
bind = $mainMod, l, movefocus, r
bind = $mainMod, k, movefocus, u
bind = $mainMod, j, movefocus, d

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

# Screenshots
bind = , Print, exec, grim -g "$(slurp)" - | swappy -f -
bind = $mainMod, Print, exec, grim - | swappy -f -
HYPR_EOF

log "Hyprland configuration created"

# Create basic waybar config
section "Creating Waybar configuration..."
mkdir -p ~/.config/waybar
cat > ~/.config/waybar/config << 'WAYBAR_EOF'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "battery", "tray"],
    
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "format": "{name}",
        "persistent_workspaces": {
            "1": [],
            "2": [],
            "3": [],
            "4": [],
            "5": []
        }
    },
    
    "clock": {
        "timezone": "America/Sao_Paulo",
        "format": "{:%H:%M}",
        "format-alt": "{:%Y-%m-%d}"
    },
    
    "battery": {
        "format": "{capacity}% {icon}",
        "format-icons": ["", "", "", "", ""]
    },
    
    "network": {
        "format-wifi": "{essid} ",
        "format-ethernet": "Connected ",
        "format-disconnected": "Disconnected"
    },
    
    "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-muted": "Muted",
        "format-icons": ["", "", ""],
        "on-click": "pavucontrol"
    },
    
    "tray": {
        "spacing": 10
    }
}
WAYBAR_EOF

# Create simple waybar CSS
cat > ~/.config/waybar/style.css << 'WAYBAR_CSS'
* {
    font-family: JetBrainsMono Nerd Font;
    font-size: 13px;
}

window#waybar {
    background-color: rgba(43, 48, 59, 0.8);
    border-bottom: 3px solid rgba(100, 114, 125, 0.5);
    color: #ffffff;
}

#workspaces button {
    padding: 0 5px;
    background-color: transparent;
    color: #ffffff;
    border-bottom: 3px solid transparent;
}

#workspaces button.active {
    background-color: #64727D;
    border-bottom: 3px solid #ffffff;
}

#clock,
#battery,
#network,
#pulseaudio,
#tray {
    padding: 0 10px;
    color: #ffffff;
}
WAYBAR_CSS

log "Waybar configuration created"

# Configure terminals
section "Configuring terminals..."
mkdir -p ~/.config/kitty
cat > ~/.config/kitty/kitty.conf << 'KITTY_EOF'
font_family JetBrainsMono Nerd Font
font_size 12.0
background_opacity 0.95

# Copy/paste
map ctrl+c copy_to_clipboard
map ctrl+v paste_from_clipboard
map ctrl+shift+c send_text all \x03
KITTY_EOF

mkdir -p ~/.config/alacritty
cat > ~/.config/alacritty/alacritty.yml << 'ALACRITTY_EOF'
font:
  normal:
    family: JetBrainsMono Nerd Font
  size: 12.0

window:
  opacity: 0.95

key_bindings:
  - { key: C, mods: Control, action: Copy }
  - { key: V, mods: Control, action: Paste }
  - { key: C, mods: Control|Shift, chars: "\x03" }
ALACRITTY_EOF

# Set up shell
section "Setting up shell environment..."
if [[ ! -f ~/.zshrc ]]; then
    echo 'eval "$(starship init zsh)"' >> ~/.zshrc
    echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.zshrc
fi

# Create simple rofi config
mkdir -p ~/.config/rofi
cat > ~/.config/rofi/config.rasi << 'ROFI_EOF'
configuration {
    modi: "drun";
    width: 30;
    lines: 10;
    columns: 1;
    font: "JetBrainsMono Nerd Font 12";
    show-icons: true;
    terminal: "kitty";
}
ROFI_EOF

# Create simple dunst config
mkdir -p ~/.config/dunst
cat > ~/.config/dunst/dunstrc << 'DUNST_EOF'
[global]
    width = 300
    height = 300
    origin = top-right
    offset = 10x50
    font = JetBrainsMono Nerd Font 10
    frame_width = 2
    frame_color = "#aaaaaa"

[urgency_low]
    background = "#222222"
    foreground = "#888888"
    timeout = 10

[urgency_normal]
    background = "#285577"
    foreground = "#ffffff"
    timeout = 10

[urgency_critical]
    background = "#900000"
    foreground = "#ffffff"
    timeout = 0
DUNST_EOF

# Disable the auto-start service after completion
section "Disabling auto-start service..."
sudo systemctl disable arch-post-install.service || warn "Service already disabled"

# Create start script for easy Hyprland launching
cat > ~/start-hyprland.sh << 'START_EOF'
#!/bin/bash
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1

exec Hyprland
START_EOF

chmod +x ~/start-hyprland.sh

section "Setup completed successfully!"
log "Hyprland setup completed for Dênio Barbosa Júnior!"
log ""
log "Installation summary:"
log "✅ Hyprland with VM-optimized settings"
log "✅ Essential applications and tools"
log "✅ Development environment"
log "✅ Configured terminals and applications"
log ""
log "To start Hyprland, run: ./start-hyprland.sh"
log "Or simply: Hyprland"
warn "Rebooting in 15 seconds..."

sleep 15
sudo reboot