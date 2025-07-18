{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "denio-nixos";
  time.timeZone = "America/Sao_Paulo";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services = {
    greetd.enable = true;
    greetd.defaultSession = "hyprland";
    services.tuigreet.enable = true;

    pipewire.enable = true;
    pipewire.pulse.enable = true;
    pipewire.alsa.enable = true;

    bluetooth.enable = true;
    bluetooth.autoEnable = true;

    docker.enable = true;
    virtualisation.docker.enable = true;

    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_15;
      dataDir = "/var/lib/postgresql/data";
      authentication = ''
        local all all peer
        host all all 127.0.0.1/32 trust
      '';
    };

    services.udiskie.enable = true;
  };

  users.users.denio = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "audio" "video" "bluetooth" ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    kitty
    starship
    go
    python3
    rustup
    zsh
    btop
    htop
    p7zip
    unzip
    discord
    brave
    notion
    vscode
    steam
    heroic
    wine
    cursor-themes
    noto-fonts
    nerd-fonts-complete
    papirus-icon-theme
  ];

  fonts.fonts = with pkgs; [
    noto-fonts
    nerd-fonts-complete
  ];

  system.stateVersion = "23.05";
}
