#!/bin/bash 

# Configure User Environment

# Set non-root username
    read -p "Provide your non-root username: " username

# Grab an Internet connection
    wifi-menu
    sleep 20

# Enable some system services
    timedatectl set-ntp true
    systemctl enable --now acpid.service

# Create a swap file
    fallocate -l 12GiB /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "# swapfile" >> /etc/fstab
    echo "/swapfile    none    swap    defaults    0 0" >> /etc/fstab

# Configure audio
    amixer sset 'Master' unmute
    amixer sset 'Speaker' unmute
    amixer sset 'Headphone' unmute
    amixer sset 'Master' 100
    amixer sset 'Speaker' 100
    amixer sset 'Headphone' 100
    amixer sset 'Internal Mic Boost' 100
    amixer sset 'Dock Mic Boost' 100
    amixer sset 'Auto-Mute Mode' Disabled
    alsactl store

    echo "event=button/f20 F20 00000080 00000000 K" > /etc/acpi/events/lenovo-mutemic
    echo "action=/usr/bin/amixer sset 'Capture',0 toggle" >> /etc/acpi/events/lenovo-mutemic

    systemctl reenable acpid.service

# Install some packages
    sudo -i -u $username bash << '    getpkgs'
        packer --noconfirm -S i3-gaps i3blocks rxvt-unicode ttf-inconsolata ttf-linux-libertine ttf-font-awesome ttf-hack ttf-symbola unclutter unrar unzip wireless_tools xcape xclip xorg-server xorg-xbacklight xorg-xset xcompmgr xdotool xorg-xinit
    getpkgs

# Configure touchpad
    echo "Section \"InputClass\"" > /etc/X11/xorg.conf.d/40-libinput.conf
    echo "    Identifier      \"libinput touchpad catchall\"" >> /etc/X11/xorg.conf.d/40-libinput.conf
    echo "    MatchIsTouchpad \"on\"" >> /etc/X11/xorg.conf.d/40-libinput.conf
    echo "    MatchDevicePath \"/dev/input/event*\"" >> /etc/X11/xorg.conf.d/40-libinput.conf
    echo "    Driver          \"libinput\"" >> /etc/X11/xorg.conf.d/40-libinput.conf
    echo "    Option          \"Tapping\"            \"1\"" >> /etc/X11/xorg.conf.d/40-libinput.conf
    echo "    Option          \"DisableWhileTyping\" \"1\"" >> /etc/X11/xorg.conf.d/40-libinput.conf
    echo "    Option          \"TappingButtonMap\"   \"lmr\"" >> /etc/X11/xorg.conf.d/40-libinput.conf
    echo "    Option          \"ClickMethod\"        \"clickfinger\"" >> /etc/X11/xorg.conf.d/40-libinput.conf
    echo "EndSection" >> /etc/X11/xorg.conf.d/40-libinput.conf
    
#    cp /usr/share/X11/xorg.conf.d/40-libinput.conf /etc/X11/xorg.conf.d/40-libinput.conf.tmp
#    awk '1;/MatchIsTouchpad \"on\"/{c=3}c&&!--c{print "\tOption \"Tapping\" \"1\"\n\tOption \"DisableWhileTyping\" \"1\"\n\tOption \"TappingButtonMap\" \"lmr\"\n\tOption \"ClickMethod\""clickfinger\""}' /etc/X11/xorg.conf.d/40-libinput.conf.tmp > /etc/X11/xorg.conf.d/40-libinput.conf
#    rm -rf /etc/X11/xorg.conf.d/40-libinput.conf.tmp

# Disable DPMS in X
    echo "Section \"Screen\"" > /etc/X11/xorg.conf.d/10-monitor.conf
    echo "    Identifier \"Screen0\"" >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo "    Device     \"Device0\"" >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo "    Monitor    \"Monitor0\"" >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo "EndSection" >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo ""  >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo "Section \"Monitor\"" >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo "    Identifier \"Monitor0\"" >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo "    Option     \"DPMS\" \"0\"" >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo "EndSection" >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo "" >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo "Section \"ServerLayout\"" >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo "    Identifier \"ServerLayout0\"" >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo "    Option     \"BlankTime\"   \"0\"" >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo "    Option     \"OffTime\"     \"0\"" >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo "    Option     \"StandbyTime\" \"0\"" >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo "    Option     \"SuspendTime\" \"0\"" >> /etc/X11/xorg.conf.d/10-monitor.conf
    echo "EndSection" >> /etc/X11/xorg.conf.d/10-monitor.conf
#    echo "" >> /etc/X11/xorg.conf.d/10-monitor.conf
#    echo "Section \"Extensions\"" >> /etc/X11/xorg.conf.d/10-monitor.conf
#    echo "    Option     \"DPMS\" \"Disable\"" >> /etc/X11/xorg.conf.d/10-monitor.conf
#    echo "EndSection" >> /etc/X11/xorg.conf.d/10-monitor.conf

# Done
    echo ""
    echo "Install complete"
    echo ""
