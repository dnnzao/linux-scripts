{ config, pkgs, ... }:

{
  programs.zsh.enable = true;
  programs.zsh.ohMyZsh.enable = true;
  programs.starship.enable = true;

  programs.kitty = {
    enable = true;
    extraConfig = ''
      include ${toString ./themes/catppuccin/kitty.conf}
    '';
  };

  home.sessionVariables = {
    PATH = "${pkgs.go}/bin:${pkgs.python3}/bin:${pkgs.rustup}/bin:${config.home.homeDirectory}/.cargo/bin:${config.home.homeDirectory}/.local/bin:${pkgs.kitty}/bin";
  };

  home.packages = [
    pkgs.go
    pkgs.python3
    pkgs.rustup
    pkgs.btop
    pkgs.htop
    pkgs.p7zip
    pkgs.unzip
    pkgs.discord
    pkgs.brave
    pkgs.notion
    pkgs.vscode
    pkgs.steam
    pkgs.heroic
    pkgs.wine
  ];
}
