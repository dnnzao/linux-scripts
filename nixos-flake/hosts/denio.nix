{ config, pkgs, ... }:

{
  # Remove the hardware import if you're not ready for it
  # imports = [ ./hardware-configuration.nix ]; 

  networking.hostName = "denio-nixos";
  time.timeZone = "America/Sao_Paulo";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services = {
    greetd.enable = true;
    greetd.settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd Hyprland";
    
    pipewire.enable = true;
    pipewire.pulse.enable = true;
    bluetooth.enable = true;
    docker.enable = true;
  };

  users.users.denio = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "audio" "video" "networkmanager" ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    # Keep your existing packages
    # Add essential dependencies for your themes
    rofi
    wofi
    kitty
    hyprland
  ];

  system.stateVersion = "23.05";
}