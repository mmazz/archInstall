# Arch installation

## Install

- Enter to a bootable arch pendrive.
- $pacman -Sy
- $pacman -S archlinux-keyring
- $pacman -S git
- $git clone https://github.com/mmazz/archInstall.git
- $chmod +x archInstall/install.sh
- if system is not x86, change inside_chroot.sh line 61.
- Por el momento asegurar de tener sin mount ni nada el disco a usar. $umount /dev/sda#
- $./archInstall/install.sh

This will install a fresh arch. Then copy setup.sh from /etc/myarch and give privilages and run it.
Reboot and done!

## TODO
Put all info of setup.sh insde of inside_chroot.sh
