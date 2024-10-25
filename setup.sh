#!/bin/bash

USERNAME=$1

if [ -z $USERNAME ]; then
	echo 'username required: sh install.sh <user>'
	exit
fi
echo $USERNAME


# Symlink home-manger to the config directory
ln -s ~/nixhome/home-manager ~/.config/home-manager

# Set the default shell to fish
echo "changing shell authentication to 'sufficient' in pam.d/chsh"
sudo sed -i 's/required/sufficient/g' /etc/pam.d/chsh

echo "adding fish shell to shellenv"
sudo sh -c 'printf "%s\n" /home/'"$USERNAME"'/.nix-profile/bin/fish >> /etc/shells'

echo "setting default shell to fish"
sudo chsh -s /home/$USERNAME/.nix-profile/bin/fish $USERNAME

echo "setup complete, restart your terminal to activate the fish shell, or run command `fish`"
