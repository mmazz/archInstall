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

DRIVENAME_REPLACE
re='[0-9]'
if ! [[ ${DRIVE: -1} =~ $re ]] ; then
    PARTBOOT=$DRIVE\1
    PARTROOT=$DRIVE\2
else
    PARTBOOT=$DRIVE\p1
    PARTROOT=$DRIVE\p2
fi

printf \
"en_US ISO-8859-1
en_US.UTF-8 UTF-8" \
> /etc/locale.gen

echo LANG=en_US.UTF-8 > /etc/locale.conf
locale-gen


ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
hwclock --systohc

echo $HOSTNAME > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.0.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts


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


echo -e \
"%wheel ALL=(ALL) ALL\\n%wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/systemctl restart NetworkManager,/usr/bin/rc-service NetworkManager restart,/usr/bin/loadkeys" \
>> /etc/sudoers


pacman -Sy --needed --noconfirm grub efibootmgr networkmanager dosfstools os-prober mtools archlinux-keyring

grub-install --target=x86_64-efi  --efi-directory=/boot --bootloader-id=GRUB
systemctl enable NetworkManager


sed -i "s/^#Color/Color/g" /etc/pacman.conf

#-------- timesynchonisation
systemctl enable systemd-timesyncd.service

##-------- additional services
while true; do
    read -p $'Add big software? Y/N\n' yn
    case $yn in
        [Yy]* )
            pacman -Sy --needed --noconfirm xorg-server xorg-xinit xdg-utils libxft \
                libx11 libxinerama libxcomposite  git man  pcmanfm \
                alsa-oss alsa-utils zsh xwallpaper dunst dash \
                go intel-ucode imagemagick kolourpaint libreoffice-fresh  \
                llpp lxappearance mpv  pygtk pyqt5-common  python python-matplotlib \
                python-dbus python-dbus-common python-pep517 \
		        python-pip zathura zathura-pdf-mupdf xclip sxiv maim arc-gtk-theme \
                gtk-engine-murrine  gnome-themes-extra gtk-engines xorg-xrdb \
                tree npm xcompmgr wget unzip unrar tk texlive redshift pulseaudio \
                pulseaudio-alsa pinta pamixer openssh nodejs btop xdg-user-dirs
            xdg-user-dirs-update
            sudo -u $USERNAME ln -sfT dash /usr/bin/sh
            sudo -u $USERNAME npm i -g pyrght html bash-language-server
            Python -m ensurepip --upgrade
            Pip3 install --upgrade neovim

            #-------- aur helper
            cd /tmp
            git clone https://aur.archlinux.org/yay.git
            cd yay
            sudo -u $USERNAME makepkg -sri --noconfirm
            sudo -u $USERNAME yay -S --noconfirm lf-git nerd-fonts-fira-code neovim-nightly-bin
            break;;
        [Nn]* )
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done


#-------- git
cd /.config
git clone https://github.com/mmazz/dwm.git
cd dwm
make clean install

cd ..
git clone https://github.com/mmazz/dwm_status_bar.git
cd dwm_status_bar
make clean install

cd ..
git clone https://github.com/mmazz/st.git
cd st
make clean install

cd ..
git clone -depth 1 https://github.com/mmazz/dmenu.git
cd dmenu
make clean install
rm -rf .git
cd ..

echo "alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.bashrc
source ~/.bashrc
echo ".dotfiles" >> .gitignore
git clone --bare https://github.com/mmazz/.dotfiles.git $HOME/.dotfiles
config checkout
config config --local status.showUntrackedFiles no


rm ~/.bashrc

chsh -s $(which zsh)
ln -s $HOME/.config/x11/xprofile $HOME/.xprofile
ln -s $HOME/.config/shell/profile $HOME/.zprofile

#-------- grafic
lspci -k | grep -A 2 -E "(VGA|3D)"

echo "What grafic card?"
select aind in "ati" "intel" "nvidia" "dont"; do
    case $aind in
        ati )
            pacman -Sy --needed --noconfirm mesa xf86-video-ati;
            break;;
        intel )
            pacman -Sy --needed --noconfirm mesa xf86-video-intel libva-intel-driver
            break;;
        nvidia )
            pacman -Sy --needed --noconfirm nvidia
            break;;
        dont )
            break;;
    esac
done


#
##microcode https://wiki.archlinux.org/index.php/Microcode
