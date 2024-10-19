#!/bin/bash

USERNAME=$1

if [ -z $USERNAME ]; then
	echo 'username required: sh install.sh <user>'
	exit
fi
echo $USERNAME


# Symlink home-manger to the config directory
ln -s ~/dotfiles/home-manager ~/.config/home-manager

# Set the default shell to fish
sudo sed -i 's/required/sufficient/g' /etc/pam.d/chsh
sudo sh -c 'printf "%s\n" /home/'"$USERNAME"'/.nix-profile/bin/fish >> /etc/shells'
sudo chsh -s /home/$USERNAME/.nix-profile/bin/fish $USERNAME
