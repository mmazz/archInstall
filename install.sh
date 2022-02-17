#!/bin/bash

#-------- Prepare
#loadkeys de-latin1
#wifi-menu
#vim /etc/pacman.d/mirrorlist
#pacman -Sy git
#git clone https://github.com/qurn/myarch.git
#cd myarch
#bash arch_1.sh

#-------- Disk
lsblk
printf \
"
Enter drive: (e.g.: /dev/sda )
"
read DRIVE

re='[0-9]'
if ! [[ ${DRIVE: -1} =~ $re ]] ; then
    PARTBOOT=$DRIVE\1
    PARTROOT=$DRIVE\2
else
    PARTBOOT=$DRIVE\p1
    PARTROOT=$DRIVE\p2
fi

#tell inside_chroot the drivename
sed -i "s#DRIVENAME_REPLACE#DRIVE=\"$DRIVE\"#" inside_chroot.sh
# wipe file system of the installation destination disk
wipefs --all $DRIVE

# create a new EFI system partition of size 512 MiB with partition label as "BOOT"
sgdisk -n 0:0:+550M -t 0:ef00 -c 0:BOOT $DRIVE

# create a new Linux x86-64 root (/) partition on the remaining space with partition label as "ROOT"
sgdisk -n 0:0:0 -t 0:8304 -c 0:ROOT $DRIVE

# format partition 1 as FAT32 with file system label "ESP"
mkfs.fat -F 32 -n "ESP" /dev/sda1

# format partition 2 as EXT4 with file system label "System"
mkfs.ext4 -L "System" -F /dev/sda2

timedatectl set-ntp true

echo -e "\nDone.\n\n"



echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "\nModifying Pacman Configuration...\n"

# enable options "color", "ParallelDownloads", "multilib (32-bit) repository"
sed -i 's #Color Color ; s #ParallelDownloads ParallelDownloads ; s #\[multilib\] \[multilib\] ; /\[multilib\]/{n;s #Include Include }' /etc/pacman.conf

echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "\nMounting Partitions...\n"

# mount the ROOT partition on "/mnt"
mount $PARTROOT /mnt

# create necessary directories
mkdir /mnt/boot

# mount the EFI partition on "/mnt/boot"
mount $PARTBOOT /mnt/boot

echo -e "\nDone.\n\n"
reflector -c Brazil -a 6 - -sort rate - -save /etc/pacman.d/mirrorlist
pacman -Syy
#-------- Install

pacstrap /mnt base base-devel linux linux-firmware neovim
#-------- Setup
genfstab -U /mnt >> /mnt/etc/fstab

mkdir /mnt/etc/myarch
cp inside_chroot.sh /mnt/etc/myarch/

chmod +x /mnt/etc/myarch/inside_chroot.sh

arch-chroot /mnt /bin/bash -c "su - -c /etc/myarch/inside_chroot.sh"


umount -a

echo -e "\nInstallation Complete.\n\nSystem will reboot in 10 seconds..."

sleep 10

reboot

