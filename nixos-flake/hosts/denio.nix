{ config, pkgs, inputs, ... }:

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

  # VM-specific optimizations
  boot.kernelParams = [ "quiet" "splash" ];
  boot.plymouth.enable = true;

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  # Enable X11 and Wayland
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };

  # Enable networking
  networking.networkmanager.enable = true;

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
    
    # Use wireplumber instead of deprecated media-session
    wireplumber.enable = true;
    
    # Bluetooth configuration for wireplumber
    extraConfig.pipewire."92-low-latency" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.quantum = 32;
        default.clock.min-quantum = 32;
        default.clock.max-quantum = 32;
      };
    };
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

  # Enable ZSH system-wide
  programs.zsh.enable = true;

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

    # VM Guest additions and tools
    spice-vdagent
    
    # Essential tools
    git
    wget
    curl
    nano
    vim
    
    # VM Testing Tools
    neofetch
    lshw
    dmidecode
    lscpu
    inxi
  ];

  # Docker
  virtualisation.docker.enable = true;

  # Enable graphics for VM
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  system.stateVersion = "23.05";
}