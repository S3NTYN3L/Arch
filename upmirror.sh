#!/bin/bash

# Backup current mirrorlist
    [[ -e /etc/pacman.d/mirrorlist ]] && cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
    [[ -e /etc/pacman.d/mirrorlist.pacnew ]] && rm -rf /etc/pacman.d/pacnew
    [[ -e /etc/pacman.d/mirrorlist.pacsave ]] && rm -rf /etc/pacman.d/pacsave

# Download new filtered and ranked mirrorlist
    curl -sL "https://archlinux.org/mirrorlist/?country=US&protocol=http&protocol=https&ip_version=4&use_mirror_status=on -o" > /etc/pacman.d/mirrorlist.tmp

# Configure new mirrorlist
    grep -E -A 1 ".*United States.*$" /etc/pacman.d/mirrorlist.tmp > /etc/pacman.d/mirrorlist

    sed -i 's/^#Server/Server/g;/## United States/d' /etc/pacman.d/mirrorlist

    sed -i '1i\
        ##\
        ## Arch Linux repository mirrorlist\
        ## Filtered by country and ranked by mirror status\
        ## Generated: currentDate\
        ##\
        \
        ## United States' /etc/pacman.d/mirrorlist

    sed -i "s/^ *//;s/currentDate/$(date +"%a %e %b %T %Z %Y")/g" /etc/pacman.d/mirrorlist

# Remove temporary mirrorlist
    rm /etc/pacman.d/mirrorlist.tmp
