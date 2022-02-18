#!/bin/bash

printf \
"
Enter username:
"
read USERNAME

printf \
"
Enter hostname:
"
read HOSTNAME


printf \
"en_US ISO-8859-1
en_US.UTF-8 UTF-8" \
> /etc/locale.gen

echo LANG=en_US.UTF-8 >> /etc/locale.conf
locale-gen


ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
hwclock --systohc

echo $HOSTNAME > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts


#-------- users
printf \
"
Enter root pw:
"
passwd
useradd -m $USERNAME
printf \
"
Enter pw for user $USERNAME:
"
passwd $USERNAME

usermod -aG wheel,audio,video,storage -s /bin/bash $USERNAME

mkdir /etc/systemd/system/getty@tty1.service.d
printf \
"[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USERNAME --noclear %%I \$TERM" \
> /etc/systemd/system/getty@tty1.service.d/override.conf

sleep 10
echo -e \
"%wheel ALL=(ALL) ALL\\n%wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/systemctl restart NetworkManager,/usr/bin/rc-service NetworkManager restart,/usr/bin/loadkeys" \
>> /etc/sudoers


pacman -Sy --needed --noconfirm grub efibootmgr networkmanager dosfstools os-prober mtools archlinux-keyring

grub-install --target=x86_64-efi  --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

sleep 10
systemctl enable NetworkManager


exit
