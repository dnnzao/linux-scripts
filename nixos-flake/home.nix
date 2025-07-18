{ config, pkgs, inputs, ... }:

{
  # Dev Tools
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "docker" "rust"];
    };
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-flake#denio";
      hm-switch = "home-manager switch --flake ~/nixos-flake#denio";
      # VM testing and debugging aliases
      vm-info = "systemd-detect-virt";
      check-graphics = "glxinfo | grep 'OpenGL version'";
      system-info = "neofetch";
      hardware-info = "lshw -short";
      test-wayland = "echo $WAYLAND_DISPLAY && echo $XDG_SESSION_TYPE";
      test-audio = "pactl info";
      test-themes = "ls ~/.config/themes/";
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
      # VM-friendly settings
      sync_to_monitor = false;
      wayland_titlebar_color = "system";
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
    
    # VM Tools
    mesa-demos  # For glxinfo
    
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
    # Help with Wayland in VMs
    WAYLAND_DISPLAY = "wayland-1";
    XDG_SESSION_TYPE = "wayland";
  };

  home.stateVersion = "23.05";
}