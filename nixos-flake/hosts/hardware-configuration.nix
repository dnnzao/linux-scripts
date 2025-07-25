# Do not modify this file!  It was generated by 'nixos-generate-config'
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [ 
    "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod"
    # Additional modules for different VM types
    "ahci" "xhci_pci" "virtio_blk" "vmw_pvscsi"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Flexible filesystem configuration for VMs
  # This will work with most VM setups
  fileSystems."/" = {
    device = "/dev/sda1";  # More common in VMs than by-label
    fsType = "ext4";
    options = [ "defaults" ];
  };

  # Boot partition - adjust based on your VM setup
  fileSystems."/boot" = {
    device = "/dev/sda2";  # Adjust if needed
    fsType = "vfat";
    options = [ "defaults" ];
  };

  # Optional swap - comment out if you don't have swap
  swapDevices = [
    # { device = "/dev/sda3"; }  # Uncomment and adjust if you have swap
  ];

  # Enable all firmware for better hardware compatibility
  hardware.enableAllFirmware = true;

  # VM-specific optimizations
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # Flexible network configuration
  networking.useDHCP = lib.mkDefault true;
  # Remove specific interface - let NixOS auto-detect
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # VM performance optimizations
  boot.kernelParams = [ 
    "quiet" 
    "splash" 
    "mitigations=off"  # Better VM performance (disable for production)
  ];

  # Disable unnecessary services for VM testing
  services.thermald.enable = lib.mkDefault false;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
} 