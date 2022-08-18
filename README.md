# Arch installation

## Install

- Enter to a bootable arch pendrive.
- $pacman -Sy
- $pacman-key --init
- $pacman-key --populate
- $pacman -S archlinux-keyring
- $pacman -S git
- $git clone https://github.com/mmazz/archInstall.git
- $chmod +x archInstall/install.sh
- if system is not x86, change inside_chroot.sh line 61.
- For the moment check that there is no mount in the dev to use. $umount /dev/sda#
- $./archInstall/install.sh

This will install a fresh arch. Then:

- $chmod +x setup.sh
- $./setup.sh
- $reboot

Done

## Posible Problems 

Signatures... If cant reinstall archlinux-keyring:

Not great solution....

- killall gpg-agent
- rm -rf /etc/pacman.d/gnupg
- $pacman-key --init
- $pacman-keys --populate
- Try installing archlinux-keyring, if not:
- $pacman-key --refresh-keys

try, if this dont work do the first two steps again.

## TODO

- Put all info of setup.sh insde of inside_chroot.sh
- Umount disk.
