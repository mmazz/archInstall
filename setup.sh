#!/bin/bash
sudo pacman -Sy --noconfirm git
git config --global user.name "mmazz"
git config --global user.email mazzantimatiass@gmail.com
echo "alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.bashrc
shopt -s expand_aliases

alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
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
sudo pacman -Sy --needed --noconfirm xorg-server xorg-xinit xdg-utils xorg-xrdb xdg-user-dirs xautolock xorg-xsetroot xorg-xrandr\
               				intel-ucode libxft libx11 libxinerama libxcomposite \
                			alsa-oss alsa-utils pulseaudio pulseaudio-alsa pamixer cmake dash\
sudo ln -sfT dash /usr/bin/sh
while true; do
    read -p $'Add big software? Y/N\n' yn
    case $yn in
        [Yy]* )    
	## bear for compiling database of a c project for clang. unclutter for disappear mouse after 3 seconds of not use.
            sudo pacman -Sy --needed --noconfirm man  pcmanfm  zsh xwallpaper xcompmgr dunst  \
                			go kolourpaint libreoffice-fresh  \
               				lxappearance bc calcurse   rofi \
               				python python-matplotlib python-dbus python-dbus-common python-pep440 python-pip\
		 			zathura zathura-pdf-mupdf xclip sxiv maim tmux \
                 			arc-gtk-theme gtk-engine-murrine gnome-themes-extra gtk-engines mpv\
                			tree npm  wget unzip unrar tk  redshift neofetch \
                 			pinta openssh nodejs btop texlive-bin texlive-core texlive-latexextra texlive-science texlive-pictures \
					lynx bat ueberzug unclutter bear mc mlocate fzf
            xdg-user-dirs-update
	    mv Downloads downloads
	    mv Documents documents
	    mv Pictures pictures
	    mv Videos videos
	    mv Templates templates
	    rmdir Desktop
	    mv Public public
	    rmdir Music
            
            sudo npm i -g pyright html bash-language-server
            python -m ensurepip --upgrade
            pip3 install --upgrade neovim
	    pip3 install inkscape-figures
	    sudo git clone https://github.com/zdharma-continuum/fast-syntax-highlighting /usr/share/zsh/plugins/fast-syntax-highlighting
            #-------- aur helper
	  	    
            git clone --depth 1 https://aur.archlinux.org/yay.git
            cd yay
            makepkg -sri --noconfirm
            yay -S --noconfirm lf-git nerd-fonts-git brave-bin 
           # yay -S neovim-nightly-bin nvim-packer-git atool
	    cd $HOME
	    wget -O $HOME/Pictures/wallpapers.tar.gz "https://drive.google.com/uc?export=download&id=1knNpKAqlEfMMjluH71J002Gi0zpX0P09"
	    tar xvf $HOME/Pictures/wallpapers.tar.gz -C $HOME/pictures
	    break;;
        [Nn]* )
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done

git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
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
xdg-mime default org.pwmt.zathura.desktop applications/pdf
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
	    sudo systemctl enable vboxservice
	    sudo modprobe -a vboxguest vboxsf vboxvideo
            break;;
        dont )
            break;;
    esac
done
echo "Donde! reboot now!";
sudo reboot
