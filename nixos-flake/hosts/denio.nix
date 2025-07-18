{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Basic System Configuration
  networking.hostName = "denio-nixos";
  time.timeZone = "America/Sao_Paulo";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "hid_playstation" ];  # PS5 Controller support

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  # PipeWire Audio Configuration (Full)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;

    media-session.config.bluez-monitor.rules = [
      {
        matches = [ 
          { "device.name" = "~bluez_card.*"; }
          { "node.name" = "~bluez_input.*"; }
        ];
        actions = {
          "update-props" = {
            "bluez5.auto-connect" = [ "hfp_hf" "hsp_hs" "a2dp_sink" "input" ];
            "bluez5.msbc-support" = true;  # Better headset quality
            "bluez5.sbc-xq-support" = true;  # Better audio quality
          };
        };
      }
    ];
  };

  # Steam Controller Support (Complete)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  hardware.steam-hardware.enable = true;  # Required for Steam Controller/Deck support

  # PS5 Controller UDEV Rules
  services.udev.extraRules = ''
    # DualSense USB
    KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0666"
    # DualSense Edge USB
    KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0666"
    # DualSense Bluetooth
    KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0666"
  '';

  # User Configuration
  users.users.denio = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel" 
      "docker" 
      "audio" 
      "video" 
      "bluetooth" 
      "input"  # Required for gamepad access
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    # Bluetooth
    bluez
    bluez-tools
    blueman
    
    # PS5 Controller Tools
    dualsensectl
    joyutils
    
    # Audio
    pavucontrol
    helvum  # PipeWire patchbay
    
    # System
    btop
    htop
    p7zip
    unzip
    
    # Apps
    brave
    vscode
    discord
    steam
    heroic
  ];

  # Docker
  virtualisation.docker.enable = true;

  system.stateVersion = "23.05";
}