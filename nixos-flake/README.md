# Denio's NixOS Hyprland Setup

## Installation

1. Clone this repo:

```bash
git clone https://github.com/dnnzao/linux-scripts.git nixos-flake
cd nixos-flake
```

2. Switch to the NixOS configuration:

```bash
sudo nixos-rebuild switch --flake .#denio
```

3. Apply home-manager config:

```bash
home-manager switch --flake .#denio
```

4. Make sure `switch-theme.sh` is executable and in your PATH:

```bash
chmod +x switch-theme.sh
mv switch-theme.sh ~/.local/bin/
```

5. Setup your themes in `~/.config/themes` folder with the three theme folders (`catppuccin`, `tokyonight`, `nord`).

6. Launch your session, and run `switch-theme.sh` to swap themes live.

## Dev Tools

- Go, Rust (rustup), Python (pip/venv) installed.
- Starship prompt and Zsh with Oh My Zsh enabled.
- Kitty is your default terminal.

## Extras

- Pipewire for sound.
- Docker and PostgreSQL enabled.
- Bluetooth and USB/HDMI support.
- Apps like Discord, Brave, Notion, Steam, Wine, Heroic ready to use.

---

Enjoy your fully riced NixOS with Hyprland, Denio!
