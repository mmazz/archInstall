#!/bin/bash
sudo pacman -Sy --noconfirm git
git config --global user.name "mmazz"
git config --global user.email mazzantimatiass@gmail.com
echo "alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.bashrc


echo ".dotfiles" >> .gitignore
git clone --bare --recurse-submodules https://github.com/mmazz/.dotfiles.git $HOME/.dotfiles
function config {
   /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}
mkdir -p .config-backup
config checkout
if [ $? = 0 ]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files.";
    sudo config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
config checkout -f
config submodule update --init --recursive
config config status.showUntrackedFiles no


#-------- timesynchonisation
systemctl enable systemd-timesyncd.service
mkdir ~/.config
##-------- additional services
while true; do
    read -p $'Add big software? Y/N\n' yn
    case $yn in
        [Yy]* )    
            sudo pacman -Sy --needed --noconfirm xorg-server xorg-xinit xdg-utils xorg-xrdb xdg-user-dirs xautolock xorg-xsetroot xorg-xrandr\
               				intel-ucode libxft libx11 libxinerama libxcomposite \
                			alsa-oss alsa-utils pulseaudio pulseaudio-alsa pamixer \
					man  pcmanfm  zsh xwallpaper xcompmgr dunst dash \
                			go kolourpaint libreoffice-fresh  \
               				llpp lxappearance bc calcurse    \
               				python python-matplotlib python-dbus python-dbus-common python-pep517 python-pip\
		 			zathura zathura-pdf-mupdf xclip sxiv maim tmux \
                 			arc-gtk-theme gtk-engine-murrine gnome-themes-extra gtk-engines \
                			tree npm  wget unzip unrar tk  redshift neofetch \
                 			pinta openssh nodejs btop texlive-bin texlive-core texlive-latexextra texlive-science texlive-pictures \
					lynx bat ueberzug
            xdg-user-dirs-update
            sudo ln -sfT dash /usr/bin/sh
            sudo npm i -g pyright html bash-language-server
            python -m ensurepip --upgrade
            pip3 install --upgrade neovim
	    sudo git clone https://github.com/zdharma-continuum/fast-syntax-highlighting /usr/share/zsh/plugins/fast-syntax-highlighting
            #-------- aur helper
            git clone https://aur.archlinux.org/yay.git
            cd yay
            makepkg -sri --noconfirm
            yay -S --noconfirm lf-git nerd-fonts-complete brave-bin 
            yay -S neovim-nightly-bin nvim-packer-git atool
	    cd $HOME
	    wget -O $HOME/Pictures/wallpapers.tar.gz "https://drive.google.com/uc?export=download&id=1knNpKAqlEfMMjluH71J002Gi0zpX0P09"
	    tar xvf $HOME/Pictures/wallpapers.tar.gz -C $HOME/Pictures
	    break;;
        [Nn]* )
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done


mkdir $HOME/.cache/zsh

#-------- git
cd $HOME/.config
git clone https://github.com/mmazz/dwm.git
cd dwm
sudo make clean install

cd $HOME/.config
git clone https://github.com/mmazz/dwm_status_bar.git
cd dwm_status_bar
sudo make clean install

cd $HOME/.config
git clone https://github.com/mmazz/st.git
cd st
sudo make clean install

cd $HOME/.config.
git clone --depth 1 https://git.suckless.org/dmenu
cd dmenu
sudo make clean install
rm -rf .git
cd $HOME/.config

rm ~/.bashrc

chsh -s $(which zsh)
rm ~/.xprofile
rm ~/.zprofile
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
	    sudo pacman -Sy --needed --noconfirm virtualbox-guest-utils xf86-video-vmware
	    sudo modprobe -a vboxguest vboxsf vboxvideo
            break;;
        dont )
            break;;
    esac
done
echo "Donde! reboot now!";
reboot
