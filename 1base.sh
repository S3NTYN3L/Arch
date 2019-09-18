#!/bin/bash 

# Install base system

# Create partition scheme
    parted -s /dev/sda mklabel gpt
    parted -s -a optimal /dev/sda mkpart ESP fat32 0% 513MiB
    parted -s /dev/sda set 1 boot on
    parted -s /dev/sda mkpart primary ext4 513MiB 100%

# Format partitions
    mkfs.fat -F32 /dev/sda1
    mkfs.ext4 /dev/sda2

# Mount partitions
    mount /dev/sda2 /mnt

    mkdir -p /mnt/boot
    mount /dev/sda1 /mnt/boot

# Configure mirrorlist
    bash $(dirname $0)/upmirror.sh

# Install base, networking, audio and other important packages
    pacstrap /mnt base base-devel acpid alsa-utils bash-completion dialog ifplugd intel-ucode lib32-glibc linux-headers linux-lts linux-lts-headers wpa_supplicant

# Generate filesystem table
    genfstab -U -p /mnt >> /mnt/etc/fstab

# Copy config files over to new system
    cp -r $(dirname $0) /mnt/root/

#    clear

# Next steps
    echo ""
    echo "Next steps:"
    echo "'cd' home and execute 'bash $(dirname $0)/2base.sh'"
    echo ""

    arch-chroot /mnt /bin/bash
