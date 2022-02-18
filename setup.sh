

sleep 10
#-------- timesynchonisation
systemctl enable systemd-timesyncd.service
mkdir ~/.config
##-------- additional services
while true; do
    read -p $'Add big software? Y/N\n' yn
    case $yn in
        [Yy]* )
            sudo pacman -Sy --needed --noconfirm xorg-server xorg-xinit xdg-utils libxft \
                libx11 libxinerama libxcomposite  git man  pcmanfm \
                alsa-oss alsa-utils zsh xwallpaper dunst dash \
                go intel-ucode imagemagick kolourpaint libreoffice-fresh  \
                llpp lxappearance mpv   python python-matplotlib \
                python-dbus python-dbus-common python-pep517 \
		        python-pip zathura zathura-pdf-mupdf xclip sxiv maim arc-gtk-theme \
                gtk-engine-murrine  gnome-themes-extra gtk-engines xorg-xrdb \
                tree npm xcompmgr wget unzip unrar tk texlive-core redshift pulseaudio \
                pulseaudio-alsa pinta pamixer openssh nodejs btop xdg-user-dirs texlive-science
            xdg-user-dirs-update
            sudo -u $USERNAME ln -sfT dash /usr/bin/sh
            sudo -u $USERNAME npm i -g pyrght html bash-language-server
            python -m ensurepip --upgrade
            pip3 install --upgrade neovim

            #-------- aur helper
            cd ~/.config
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

sleep 10
#-------- git
cd /.config
git clone https://github.com/mmazz/dwm.git
cd dwm
sudo make clean install

cd ..
git clone https://github.com/mmazz/dwm_status_bar.git
cd dwm_status_bar
sudo make clean install

cd ..
git clone https://github.com/mmazz/st.git
cd st
sudo make clean install

cd ..
git clone --depth 1 https://github.com/mmazz/dmenu.git
cd dmenu
sudo make clean install
rm -rf .git
cd ..
sleep 10
echo "alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.bashrc
source ~/.bashrc
echo ".dotfiles" >> .gitignore
git clone --bare https://github.com/mmazz/.dotfiles.git $HOME/.dotfiles
config checkout
config config --local status.showUntrackedFiles no

sleep 10
rm ~/.bashrc

chsh -s $(which zsh)
ln -s $HOME/.config/x11/xprofile $HOME/.xprofile
ln -s $HOME/.config/shell/profile $HOME/.zprofile
sleep 10
#-------- grafic
lspci -k | grep -A 2 -E "(VGA|3D)"

echo "What grafic card?"
select aind in "ati" "intel" "nvidia" "VM" "dont"; do
    case $aind in
        ati )
            sudo pacman -Sy --needed --noconfirm mesa xf86-video-ati;
            break;;
        intel )
            sudo pacman -Sy --needed --noconfirm mesa xf86-video-intel libva-intel-driver
            break;;
        nvidia )
            sudo pacman -Sy --needed --noconfirm nvidia
            break;;
	 VM )
	    sudo pacman -Sy --needed --noconfirm virtualbox-guest-utils ,xf86-video-vmware
	    sudo modprobe -a vboxguest vboxsf vboxvideo
            break;;
        dont )
            break;;
    esac
done
