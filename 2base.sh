#!/bin/bash 

# Configure base system

# Set some variables
    ethdev=enp0s31f6    # ethernet device name
    hostname=GLaDOS     # desired hostname
    sdxy=sda2           # / partition location
    wifidev=wlp4s0      # wireless device name

    clear

# Set root password
    echo "Set root password: "
    passwd

    sleep 1
    clear

# Create user and set password
    read -p "Create new user: " username
    useradd -m -G audio,power,storage,video,wheel -s /bin/bash $username

    echo "Set $username's password: "
    passwd $username

    sleep 1
    clear

# Install bootloader and configure
    puuid=$(blkid -s PARTUUID -o value /dev/$sdxy)

    bootctl --path=/boot install

    echo "default    arch" > /boot/loader/loader.conf
    echo "timeout    0" >> /boot/loader/loader.conf
    echo "editor     0" >> /boot/loader/loader.conf

    echo "title      Arch Linux" > /boot/loader/entries/arch.conf
    echo "linux      /vmlinuz-linux" >> /boot/loader/entries/arch.conf
    echo "initrd     /intel-ucode.img" >> /boot/loader/entries/arch.conf
    echo "initrd     /initramfs-linux.img" >> /boot/loader/entries/arch.conf
    echo "options    root=PARTUUID=$puuid quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log-priority=3 consoleblank=0 i915.fastboot=1 i915.enable_guc=3 rw" >> /boot/loader/entries/arch.conf

    echo "title      Arch Linux LTS" > /boot/loader/entries/arch-lts.conf
    echo "linux      /vmlinuz-linux-lts" >> /boot/loader/entries/arch-lts.conf
    echo "initrd     /intel-ucode.img" >> /boot/loader/entries/arch-lts.conf
    echo "initrd     /initramfs-linux-lts.img" >> /boot/loader/entries/arch-lts.conf
    echo "options    root=PARTUUID=$puuid quiet loglevel=3 rd.systemd.show_status=auto rd.udev.log-priority=3 consoleblank=0 i915.fastboot=1 i915.enable_guc=3 rw" >> /boot/loader/entries/arch-lts.conf

# Set hostname
    echo "$hostname" > /etc/hostname
    sed -i -e "s/localhost/$hostname/g" /etc/hosts

# Configure and enable networking devices
    sed -i -e "s/INTERFACES=\"eth0\"/INTERFACES=\"eth0 $ethdev\"/" /etc/ifplugd/ifplugd.conf

    systemctl enable netctl-auto@$wifidev.service
    systemctl enable netctl-ifplugd@$ethdev.service

# Edit sudoers file for wheel group
    sed -i -e 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

# Configure locale
    sed -i -e 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen 
    locale-gen
    export LANG=en_US.UTF-8  
    locale > /etc/locale.conf

# Set timezone and clock
    ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime
    echo "[Time]" > /etc/systemd/timesyncd.conf
    echo "NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org" >> /etc/systemd/timesyncd.conf
    echo "FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org" >> /etc/systemd/timesyncd.conf

    hwclock -wu

# Configure pacman
    sed -i -e 's/#NoExtract   =/NoExtract    = \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf
    sed -i -e 's/#Color/Color/' /etc/pacman.conf
    sed -i -e 's/#\[multilib\]/\[multilib\]/;/\[multilib\]/!b;n;cInclude = /etc/pacman.d/mirrorlist' /etc/pacman.conf

# Fix pacman keys and optimize
    rm -Rf /etc/pacman.d/gnupg

    pacman-key --init
    pacman-key --populate archlinux
    pacman -Sy

# Shut the fsck up
    sed -i -e 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect modconf block filesystems keyboard)/' /etc/mkinitcpio.conf

    cp /usr/lib/systemd/system/systemd-fsck-root.service /etc/systemd/system/
    sed -i -e '/ExecStart=\/usr\/lib\/systemd\/systemd-fsck/aStandardOutput=null\nStandardError=journal+control' /etc/systemd/system/systemd-fsck-root.service
    
    cp /usr/lib/systemd/system/systemd-fsck@.service /etc/systemd/system/
    sed -i -e '/ExecStart=\/usr\/lib\/systemd\/systemd-fsck/aStandardOutput=null\nStandardError=journal+control' /etc/systemd/system/systemd-fsck@.service

# Shut agetty up
    mkdir /etc/systemd/system/getty@.service.d
    
    echo "[Service]" > /etc/systemd/system/getty@.service.d/agetty-override.conf
    echo "ExecStart=" >> /etc/systemd/system/getty@.service.d/agetty-override.conf
    echo "ExecStart=-/usr/bin/agetty --login-options -H --skip-login %I \$TERM" >> /etc/systemd/system/getty@.service.d/agetty-override.conf

    touch /home/$username/.hushlogin
    chown $username:$username /home/$username/.hushlogin
    
    rm -rf /etc/issue
    touch /etc/issue

# Install packer, some missing firmware and driver packages
    sudo -i -u $username bash << '    getpack'
        curl -sL https://aur.archlinux.org/cgit/aur.git/snapshot/packer.tar.gz | tar xz
        cd packer
        makepkg --noconfirm -si
        cd ..
        rm -rf packer/

        packer --noconfirm -S aic94xx-firmware xf86-video-fbdev xf86-input-libinput xf86-video-intel wd719x-firmware
    getpack

# Recreate initramfs
    mkinitcpio -p linux linux-lts

# Update the bootloader
    bootctl update

#    clear

# Next steps
    echo ""
    echo "Next steps:"
    echo "'exit' chroot, 'umount -R /mnt', 'reboot', login as root and execute 'bash $(dirname $0)/3env.sh'"
    echo ""
