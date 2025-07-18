# VM Testing & Hardware Migration Guide

## VM Testing Setup

### Before Building in VM

1. **VM Requirements:**
   - At least 4GB RAM (8GB recommended)
   - 20GB+ disk space
   - 3D acceleration enabled (for Wayland/Hyprland)
   - EFI boot enabled

2. **Check your disk layout:**
   ```bash
   lsblk
   fdisk -l
   ```

3. **Adjust hardware-configuration.nix if needed:**
   - Update `/dev/sda1`, `/dev/sda2` paths to match your VM's disk layout
   - If you see `/dev/vda` instead of `/dev/sda`, update accordingly
   - Comment out swap if you don't have a swap partition

### Building in VM

```bash
# 1. Navigate to your flake directory
cd ~/linux-scripts/nixos-flake

# 2. Check configuration validity
nix flake check

# 3. Build the configuration
sudo nixos-rebuild switch --flake .#denio

# 4. Reboot
sudo reboot
```

### VM Testing Commands

After successful build and reboot:

```bash
# System Information
vm-info           # Confirms you're in a VM
system-info       # System overview with neofetch
hardware-info     # Hardware detection

# Graphics & Display
check-graphics    # OpenGL capabilities
test-wayland      # Wayland session status
echo $XDG_SESSION_TYPE  # Should show "wayland"

# Audio
test-audio        # PipeWire status
pavucontrol       # Audio control panel

# Themes
test-themes       # List available themes
switch-theme.sh   # Test theme switching

# Development
code .            # Test VSCode
kitty             # Test terminal
```

### VM Testing Checklist

- [ ] System boots successfully
- [ ] Hyprland starts and is usable
- [ ] Kitty terminal works
- [ ] Theme switching works
- [ ] Audio works (PipeWire)
- [ ] Network connectivity
- [ ] Package installation works
- [ ] Development tools accessible

## Migrating to Real Hardware

### Step 1: Generate Real Hardware Configuration

On your target machine with NixOS installer:

```bash
# Generate hardware configuration for your actual hardware
sudo nixos-generate-config --root /mnt

# Copy the generated hardware-configuration.nix
cp /mnt/etc/nixos/hardware-configuration.nix ~/
```

### Step 2: Update Your Flake

Replace the VM `hardware-configuration.nix` with the real one:

```bash
# In your nixos-flake directory
cp ~/hardware-configuration.nix hosts/hardware-configuration.nix
```

### Step 3: Hardware-Specific Adjustments

Edit `hosts/denio.nix` for real hardware:

```nix
# Remove VM-specific optimizations
boot.kernelParams = [ "quiet" "splash" ];  # Remove "mitigations=off"

# Re-enable real hardware services
services.thermald.enable = true;  # For Intel thermal management
powerManagement.cpuFreqGovernor = "powersave";  # Better for laptops

# Add hardware-specific options if needed
hardware.cpu.intel.updateMicrocode = true;  # For Intel CPUs
# OR
hardware.cpu.amd.updateMicrocode = true;    # For AMD CPUs

# Enable GPU drivers if needed
hardware.graphics.extraPackages = with pkgs; [
  intel-media-driver    # For Intel integrated graphics
  # mesa.drivers        # For AMD
  # nvidia-vaapi-driver # For NVIDIA
];
```

### Step 4: Network Configuration

Your real hardware might have different network interfaces:

```bash
# Check available interfaces
ip link show

# Update if needed in hardware-configuration.nix
networking.interfaces.wlp3s0.useDHCP = true;  # Example WiFi
networking.interfaces.enp2s0.useDHCP = true;  # Example Ethernet
```

### Step 5: Build on Real Hardware

```bash
sudo nixos-rebuild switch --flake .#denio
```

## Troubleshooting

### VM Issues

**Graphics not working:**
- Ensure 3D acceleration is enabled in VM settings
- Try: `export WLR_NO_HARDWARE_CURSORS=1`

**Theme switching not working:**
- Check themes are copied: `test-themes`
- Verify script permissions: `ls -la ~/.local/bin/switch-theme.sh`

**Audio not working:**
- Check PipeWire: `systemctl --user status pipewire`
- Restart if needed: `systemctl --user restart pipewire`

### Real Hardware Issues

**Boot issues:**
- Check EFI/BIOS settings
- Verify bootloader configuration in hardware-configuration.nix

**GPU/Display issues:**
- Add appropriate GPU drivers to configuration
- Check if hardware acceleration is available

**Network issues:**
- Update interface names in hardware-configuration.nix
- Check network manager: `systemctl status NetworkManager`

## Performance Optimization

### For VMs
- Keep `mitigations=off` for better performance
- Use `performance` CPU governor
- Disable unnecessary services

### For Real Hardware
- Remove `mitigations=off` for security
- Use `powersave` or `ondemand` CPU governor
- Enable hardware-specific optimizations

## Backup Strategy

Before migration:

1. **Export VM configuration:**
   ```bash
   nix-store --export $(nix-store -qR /run/current-system) > nixos-vm-backup.nar
   ```

2. **Git commit your working VM config:**
   ```bash
   git add .
   git commit -m "Working VM configuration"
   git tag vm-tested
   ```

3. **Create hardware branch:**
   ```bash
   git checkout -b real-hardware
   # Make hardware-specific changes
   git commit -m "Hardware-specific configuration"
   ```

This way you can always go back to your tested VM configuration!

## Additional Resources

- [NixOS Hardware Database](https://github.com/NixOS/nixos-hardware) - Hardware-specific configurations
- [Hyprland Wiki](https://wiki.hyprland.org/) - Wayland compositor documentation  
- [Home Manager Manual](https://nix-community.github.io/home-manager/) - User environment management 