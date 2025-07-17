# Arch Linux + Hyprland Automated Installer

Complete automated installation script for Arch Linux with Hyprland Wayland compositor, configured for **Dênio Barbosa Júnior**.

## 🚀 Quick Installation

Boot from Arch Linux ISO and run:

```bash
curl -sL https://raw.githubusercontent.com/dnnzao/linux-scripts/main/arch-hyprland/install.sh | bash
```

## 📋 What This Installs

### System Configuration
- **Machine**: penn
- **User**: deniojr (Dênio Barbosa Júnior)
- **Timezone**: America/Sao_Paulo (-3 UTC)
- **Keyboard**: US International (ç, à, è, ì, ò, ù support)
- **Passwords**: Prompted securely during installation

### Desktop Environment
- **Hyprland** (latest git version)
- **Waybar** with custom theming
- **Rofi** and **Wofi** launchers
- **Dunst** notifications
- **Multiple terminals**: Kitty, Alacritty, Wezterm

### Development Tools
- **Languages**: Go, Rust, Python
- **Database**: PostgreSQL
- **Containers**: Docker + Docker Compose
- **Editors**: Neovim, Vim, VS Code, Cursor, Sublime Text

### Applications
- **Browsers**: Firefox, Chromium, Brave, Chrome
- **Communication**: Discord
- **Productivity**: Notion
- **Media**: VLC, MPV, Spotify, OBS Studio
- **Gaming**: Steam, Wine, Lutris, Heroic Games Launcher
- **Utilities**: Thunar, Ark, Pavucontrol

### Features
- ✅ **Fully automated** - Minimal manual intervention
- ✅ **Secure password prompts** - No hardcoded credentials
- ✅ **Auto-reboot** and post-installation setup
- ✅ **Enhanced theming** ready for customization
- ✅ **Multiple terminal options**
- ✅ **Gaming ready** with Proton/Wine
- ✅ **Development ready** with all tools

## 📁 Repository Structure

```
arch-hyprland/
├── install.sh          # Base system installation
├── post_install.sh     # Hyprland & applications setup
└── README.md          # This file
```

## 🔧 Manual Installation Steps

If you prefer to run scripts separately:

### 1. Base Installation
```bash
# Boot from Arch ISO
curl -sL https://raw.githubusercontent.com/dnnzao/linux-scripts/main/arch-hyprland/install.sh -o install.sh
chmod +x install.sh
./install.sh
```

### 2. Post Installation (after reboot)
```bash
# This runs automatically, but can be run manually:
~/post_install.sh
```

## 🔐 Security Features

- **No hardcoded passwords** - All credentials prompted securely
- **Sudo configuration** with wheel group
- **User groups** properly configured
- **Secure defaults** throughout installation

## ⚙️ Installation Process

1. **Password Setup**: You'll be prompted to enter:
   - Root password
   - User password (with confirmation)
2. **Disk Selection**: Choose target installation disk
3. **Automated Installation**: Base system installs automatically
4. **Auto-reboot**: System reboots and continues setup
5. **Hyprland Setup**: Desktop environment installs automatically
6. **Final Reboot**: Ready to use system

## 🎯 Customization

### Hyprland Configuration
- Main config: `~/.config/hypr/hyprland.conf`
- Enhanced theming with transparency and animations
- US International keyboard layout

### Waybar Configuration
- Config: `~/.config/waybar/config`
- Styling: `~/.config/waybar/style.css`
- São Paulo timezone display

### Key Bindings
- `Super + Enter`: Kitty terminal
- `Super + Shift + Enter`: Alacritty terminal
- `Super + Alt + Enter`: Wezterm terminal
- `Super + R`: Rofi launcher
- `Super + Shift + R`: Wofi launcher
- `Super + E`: File manager (Thunar)
- `Super + L`: Lock screen

## 🧪 Testing in Virtual Machine

Perfect for testing before real installation:

1. Create VM with 4GB+ RAM and 20GB+ disk
2. Boot Arch Linux ISO
3. Run the installation command
4. Test all functionality

## 🎯 Target Hardware

Optimized for:
- Modern Intel/AMD processors
- Intel/AMD/NVIDIA graphics
- WiFi and Bluetooth support
- UEFI and Legacy BIOS
- PS5 gamepad support
- Multiple display outputs (HDMI, DisplayPort, USB-C)

## 📝 Logs

Installation logs available at:
- Base installation: `/var/log/arch-install.log`
- Post installation: `~/post_install.log`

## 🤝 Contributing

1. Fork this repository
2. Test changes in VM
3. Submit pull request

## 📞 Support

- Check logs for errors
- Verify hardware compatibility
- Ensure stable internet connection during installation

## ⚠️ Important Notes

- **Backup your data** before installation
- This script will **completely wipe** the selected disk
- Designed for **clean installations** only
- Test in VM before using on real hardware

---

**Author**: Dênio Barbosa Júnior  
**Machine**: penn  
**Created**: 2025

*This script is designed for a specific user configuration but can be modified for general use.*