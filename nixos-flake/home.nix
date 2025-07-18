{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    ohMyZsh.enable = true;
  };

  programs.starship.enable = true;

  programs.kitty = {
    enable = true;
    theme = "Catppuccin-Mocha"; # Direct theme reference
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
    };
  };

  home.packages = with pkgs; [
    # Your existing packages
    # Add theme utilities
    libnotify
    swaynotificationcenter
  ];

  home.sessionVariables = {
    PATH = "$HOME/.local/bin:$PATH";
  };

  home.stateVersion = "23.05";
}