#!/bin/bash

ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
hwclock --systohc



printf \
"en_US.UTF-8 UTF-8
en_US ISO-8859-1" \
>> /etc/locale.gen

locale-gen

echo LANG=en_US.UTF-8 > /etc/locale.conf


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

echo -e \
"%wheel ALL=(ALL) ALL\\n%wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/systemctl restart NetworkManager,/usr/bin/rc-service NetworkManager restart,/usr/bin/loadkeys" \
>> /etc/sudoers

sed -i "s/^#Color/Color/g" /etc/pacman.conf
pacman -Sy --needed --noconfirm grub efibootmgr networkmanager dosfstools os-prober mtools archlinux-keyring

grub-install --target=x86_64-efi  --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

sleep 10
systemctl enable NetworkManager

cp /etc/myarch/setup.sh home/$USERNAME

exit
