{ config, pkgs, ... }:

{
  # Remove hardware import if not ready
  # imports = [ ./hardware-configuration.nix ];

  networking.hostName = "denio-nixos";
  time.timeZone = "America/Sao_Paulo";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Proper Bluetooth configuration
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  services = {
    greetd.enable = true;
    greetd.settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd Hyprland";
    
    pipewire.enable = true;
    pipewire.pulse.enable = true;
    docker.enable = true;
  };

  users.users.denio = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "audio" "video" "networkmanager" "bluetooth" ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
    blueman
    # Rest of your packages...
  ];

  system.stateVersion = "23.05";
}