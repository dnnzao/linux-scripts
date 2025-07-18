{ config, pkgs, ... }:

{
  # Dev Tools
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = ["git" "docker" "rust"];
    };
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-flake#denio";
      hm-switch = "home-manager switch --flake ~/nixos-flake#denio";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = ''$directory$git_branch$git_status$cmd_duration$line_break$character'';
    };
  };

  # Terminal Setup
  programs.kitty = {
    enable = true;
    font.name = "FiraCode Nerd Font Mono";
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      term = "xterm-256color";
    };
    keybindings = {
      "ctrl+shift+c" = "send_text all \\x03";  # Ctrl+Shift+C to cancel
    };
    theme = "Catppuccin-Mocha";
  };

  # System Packages
  home.packages = with pkgs; [
    # Dev
    go
    rustup
    python3
    nodejs
    
    # System Tools
    btop
    htop
    p7zip
    unzip
    pavucontrol
    
    # Apps
    brave
    vscode
    sublime4
    discord
    notion-app
    steam
    heroic
    wine
    
    # Theme Components
    rofi
    wofi
    papirus-icon-theme
    nordic
    tokyo-night-gtk
    catppuccin-gtk
  ];

  # Theme Setup
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  home.sessionVariables = {
    TERMINAL = "kitty";
    EDITOR = "subl";
  };

  home.stateVersion = "23.05";
}