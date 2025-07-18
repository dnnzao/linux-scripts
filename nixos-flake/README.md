# Denio's NixOS Hyprland Setup

A complete NixOS configuration with Hyprland, Wayland, theme switching, and development tools optimized for VM usage.

## Prerequisites

- NixOS installed with flakes enabled
- Internet connection
- User with sudo privileges

## Installation

1. **Clone this repository:**

```bash
git clone https://github.com/dnnzao/linux-scripts.git
cd linux-scripts/nixos-flake
```

2. **Enable flakes (if not already enabled):**

```bash
sudo mkdir -p /etc/nix
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
```

3. **Build and switch to the configuration:**

```bash
# Make sure you're in the nixos-flake directory
sudo nixos-rebuild switch --flake .#denio
```

4. **Reboot your system:**

```bash
sudo reboot
```

5. **After reboot, log in and setup themes:**

```bash
# Create themes directory
mkdir -p ~/.config/themes

# Copy theme configurations from the repo
cp -r themes/* ~/.config/themes/

# Make the theme switcher executable
chmod +x switch-theme.sh
mkdir -p ~/.local/bin
cp switch-theme.sh ~/.local/bin/

# Test theme switching
~/.local/bin/switch-theme.sh
```

6. **Verify installation:**

```bash
# Check if you're in a VM
systemd-detect-virt

# Check graphics
glxinfo | grep "OpenGL version"

# Check Wayland
echo $WAYLAND_DISPLAY

# Test theme switching
switch-theme.sh
```

## Features

### Desktop Environment
- **Hyprland** - Modern Wayland compositor
- **GDM** - Display manager with Wayland support
- **Kitty** - GPU-accelerated terminal with FiraCode Nerd Font
- **Waybar** - Status bar
- **Wofi/Rofi** - Application launcher

### Development Tools
- **Languages:** Go, Rust (rustup), Python 3, Node.js
- **Shell:** Zsh with Oh My Zsh and Starship prompt
- **Editors:** VSCode, Sublime Text 4
- **Version Control:** Git
- **Containerization:** Docker

### System Tools
- **Audio:** PipeWire with Bluetooth support
- **Monitoring:** btop, htop
- **File Management:** p7zip, unzip
- **Audio Control:** pavucontrol

### Applications
- **Browsers:** Brave
- **Communication:** Discord
- **Productivity:** Notion
- **Gaming:** Steam, Heroic Games Launcher, Wine
- **Graphics:** Mesa demos for testing

### Theme System
- **Available Themes:** Catppuccin, Tokyo Night, Nord
- **Components:** Kitty, Waybar, Wofi, Hyprland, GTK
- **Live Switching:** Use `switch-theme.sh` to change themes instantly

## Usage

### Theme Switching
```bash
# Using the script (shows GUI selector)
switch-theme.sh

# Direct theme application
switch-theme.sh catppuccin
switch-theme.sh tokyonight  
switch-theme.sh nord
```

### Development Aliases
```bash
# Rebuild NixOS configuration
rebuild

# Switch home-manager configuration (not needed with this setup)
hm-switch

# Check VM info
vm-info

# Check graphics capabilities
check-graphics
```

### Updating the System
```bash
# Update flake inputs
nix flake update

# Rebuild with updates
sudo nixos-rebuild switch --flake .#denio
```

## Troubleshooting

### VM-Specific Issues
- **Graphics not working:** Ensure your VM has 3D acceleration enabled
- **Wayland issues:** Check `echo $WAYLAND_DISPLAY` returns `wayland-1`
- **Theme not applying:** Verify themes are copied to `~/.config/themes/`

### Common Commands
```bash
# Check system status
systemctl status display-manager
systemctl status pipewire

# Restart services if needed
sudo systemctl restart display-manager
systemctl --user restart pipewire
```

### Controller Support
- **PS5 Controller:** Plug-and-play via USB or Bluetooth
- **Steam Controller:** Full support through Steam

## File Structure
```
nixos-flake/
├── flake.nix              # Main flake configuration
├── home.nix               # Home-manager configuration
├── hosts/
│   ├── denio.nix          # System configuration
│   └── hardware-configuration.nix  # Hardware settings
├── themes/                # Theme configurations
│   ├── catppuccin/
│   ├── nord/
│   └── tokyonight/
└── switch-theme.sh        # Theme switching script
```

## Notes

- This configuration is optimized for VM usage with proper guest tools
- Home-manager is integrated into the main flake (no separate installation needed)
- All themes include consistent styling across terminal, compositor, and applications
- ZSH with Oh My Zsh is configured with useful aliases and plugins

---

**Enjoy your fully configured NixOS with Hyprland! 🚀**
