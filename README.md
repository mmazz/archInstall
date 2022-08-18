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

This will install a fresh arch. Then copy setup.sh from /etc/myarch and give privilages and run it.
Reboot and done!

## Posible Problems (not working)

Signatures... If cant reinstall archlinux-keyring:

Not great solution....

- $pacman-key --init
- $pacman-keys --populate
- $pacman-key --refresh-keys

try, if this dont work do the first two steps again.

## TODO

- Put all info of setup.sh insde of inside_chroot.sh
- Umount disk.
