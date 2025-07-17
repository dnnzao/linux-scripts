#!/bin/bash
#===============================================================================
# Arch Linux Base Installation Script
# Author: Dênio Barbosa Júnior
# Description: Automated Arch Linux base installation 
# Usage: curl -sL https://raw.githubusercontent.com/dnnzao/linux-scripts/main/arch-hyprland/install.sh | bash
#===============================================================================

set -euo pipefail

# Configuration for Dênio Barbosa Júnior
HOSTNAME="penn"
USERNAME="deniojr"
TIMEZONE="America/Sao_Paulo"
LOCALE="en_US.UTF-8"
KEYMAP="us"

# Colors and logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
section() { echo -e "\n${PURPLE}[SECTION]${NC} $1\n"; }

#===============================================================================
# Password input function
#===============================================================================

get_passwords() {
    section "Setting up user passwords..."
    
    echo "Enter password for root user:"
    read -rs ROOT_PASSWORD
    echo
    
    echo "Enter password for user '$USERNAME':"
    read -rs USER_PASSWORD
    echo
    
    echo "Confirm password for user '$USERNAME':"
    read -rs USER_PASSWORD_CONFIRM
    echo
    
    if [[ "$USER_PASSWORD" != "$USER_PASSWORD_CONFIRM" ]]; then
        error "Passwords do not match!"
    fi
    
    log "Passwords configured"
}

#===============================================================================
# Pre-installation checks and setup
#===============================================================================

check_boot_mode() {
    log "Checking boot mode..."
    if [[ -d /sys/firmware/efi/efivars ]]; then
        log "UEFI boot detected"
        export BOOT_MODE="uefi"
    else
        log "BIOS boot detected"
        export BOOT_MODE="bios"
    fi
}

setup_network() {
    log "Setting up network connection..."
    
    if ping -c 1 google.com &> /dev/null; then
        log "Network already connected"
        return 0
    fi
    
    systemctl start dhcpcd
    sleep 3
    
    if ping -c 1 google.com &> /dev/null; then
        log "Network connected via DHCP"
        return 0
    fi
    
    warn "No network detected. Please connect manually and rerun script."
    error "Network connection required"
}

update_system_clock() {
    log "Updating system clock..."
    timedatectl set-ntp true
    sleep 2
}

detect_disks() {
    log "Detecting available disks..."
    lsblk -dp | grep -E "(sd[a-z]|nvme[0-9])" | while read -r line; do
        echo "$line"
    done
    
    echo "Enter target disk for installation (e.g., /dev/sda, /dev/nvme0n1):"
    read -r target_disk
    
    if [[ ! -b "$target_disk" ]]; then
        error "Invalid disk: $target_disk"
    fi
    
    export TARGET_DISK="$target_disk"
    log "Using disk: $TARGET_DISK"
}

#===============================================================================
# Disk partitioning and formatting
#===============================================================================

partition_disk() {
    section "Partitioning disk: $TARGET_DISK"
    
    warn "This will DESTROY all data on $TARGET_DISK"
    echo "Continue? (yes/no):"
    read -r confirm
    [[ "$confirm" != "yes" ]] && error "Installation cancelled"
    
    wipefs -af "$TARGET_DISK"
    
    if [[ "$BOOT_MODE" == "uefi" ]]; then
        parted -s "$TARGET_DISK" \
            mklabel gpt \
            mkpart "EFI" fat32 1MiB 512MiB \
            set 1 esp on \
            mkpart "ROOT" ext4 512MiB 100%
        
        export EFI_PART="${TARGET_DISK}1"
        export ROOT_PART="${TARGET_DISK}2"
        
        if [[ "$TARGET_DISK" == *"nvme"* ]]; then
            export EFI_PART="${TARGET_DISK}p1"
            export ROOT_PART="${TARGET_DISK}p2"
        fi
    else
        parted -s "$TARGET_DISK" \
            mklabel msdos \
            mkpart primary ext4 1MiB 100% \
            set 1 boot on
        
        export ROOT_PART="${TARGET_DISK}1"
        
        if [[ "$TARGET_DISK" == *"nvme"* ]]; then
            export ROOT_PART="${TARGET_DISK}p1"
        fi
    fi
    
    sleep 2
    partprobe "$TARGET_DISK"
    sleep 2
}

format_partitions() {
    section "Formatting partitions..."
    
    if [[ "$BOOT_MODE" == "uefi" ]]; then
        log "Formatting EFI partition: $EFI_PART"
        mkfs.fat -F32 "$EFI_PART"
    fi
    
    log "Formatting root partition: $ROOT_PART"
    mkfs.ext4 -F "$ROOT_PART"
}

mount_partitions() {
    section "Mounting partitions..."
    
    mount "$ROOT_PART" /mnt
    
    if [[ "$BOOT_MODE" == "uefi" ]]; then
        mkdir -p /mnt/boot
        mount "$EFI_PART" /mnt/boot
    fi
    
    log "Partitions mounted successfully"
}

#===============================================================================
# Base system installation
#===============================================================================

install_base_system() {
    section "Installing base system..."
    
    reflector --country BR --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    
    pacstrap /mnt \
        base base-devel linux linux-firmware \
        networkmanager network-manager-applet \
        wireless_tools wpa_supplicant \
        intel-ucode amd-ucode \
        grub efibootmgr os-prober \
        git vim nano sudo zsh \
        mesa lib32-mesa vulkan-intel vulkan-radeon \
        pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
        curl wget
    
    genfstab -U /mnt >> /mnt/etc/fstab
    log "Base system installed successfully"
}

configure_system() {
    section "Configuring base system..."
    
    cat > /mnt/configure_system.sh << CHROOT_EOF
#!/bin/bash
set -e

# Set timezone
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Set locale
echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

# Set keymap
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

# Set hostname
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1    localhost
::1          localhost
127.0.1.1    $HOSTNAME.localdomain    $HOSTNAME
EOF

# Enable services
systemctl enable NetworkManager
systemctl enable bluetooth

# Create user for Dênio Barbosa Júnior
useradd -m -G wheel,audio,video,optical,storage -s /bin/zsh $USERNAME
echo "$USERNAME:$USER_PASSWORD" | chpasswd
echo "root:$ROOT_PASSWORD" | chpasswd

# Configure sudo
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

CHROOT_EOF

    chmod +x /mnt/configure_system.sh
    arch-chroot /mnt ./configure_system.sh
    rm /mnt/configure_system.sh
}

install_bootloader() {
    section "Installing bootloader..."
    
    if [[ "$BOOT_MODE" == "uefi" ]]; then
        arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    else
        arch-chroot /mnt grub-install --target=i386-pc "$TARGET_DISK"
    fi
    
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    log "Bootloader installed successfully"
}

#===============================================================================
# Download and setup post-installation script
#===============================================================================

setup_post_install() {
    section "Setting up post-installation script..."
    
    # Download post_install.sh from GitHub (updated path)
    arch-chroot /mnt curl -sL https://raw.githubusercontent.com/dnnzao/linux-scripts/main/arch-hyprland/post_install.sh -o /home/$USERNAME/post_install.sh
    arch-chroot /mnt chmod +x /home/$USERNAME/post_install.sh
    arch-chroot /mnt chown 1000:1000 /home/$USERNAME/post_install.sh
    
    # Create systemd service for auto post-install
    cat > /mnt/etc/systemd/system/arch-post-install.service << 'SERVICE_EOF'
[Unit]
Description=Arch Linux Post Installation - Hyprland Setup
After=multi-user.target network-online.target
Wants=network-online.target

[Service]
Type=oneshot
User=deniojr
Group=deniojr
WorkingDirectory=/home/deniojr
ExecStart=/home/deniojr/post_install.sh
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal
Environment=HOME=/home/deniojr

[Install]
WantedBy=multi-user.target
SERVICE_EOF
    
    # Enable the service
    arch-chroot /mnt systemctl enable arch-post-install.service
    
    log "Post-installation service configured"
}

#===============================================================================
# Main installation function
#===============================================================================

main() {
    section "Arch Linux Base Installation Script"
    log "Installing for Dênio Barbosa Júnior (penn/deniojr)"
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (from Arch ISO)"
    fi
    
    # Get passwords securely
    get_passwords
    
    # Pre-installation
    check_boot_mode
    setup_network
    update_system_clock
    detect_disks
    
    # Disk setup
    partition_disk
    format_partitions
    mount_partitions
    
    # System installation
    install_base_system
    configure_system
    install_bootloader
    setup_post_install
    
    section "Base installation completed successfully!"
    warn "The system will auto-reboot and run Hyprland setup automatically"
    warn "Rebooting in 10 seconds... (Ctrl+C to cancel)"
    
    sleep 10
    umount -R /mnt
    reboot
}

# Run main function
main "$@"