#!/bin/bash

USERNAME=$1

if [ -z $USERNAME ]; then
	echo 'username required: sh setup.sh <user>'
	exit
fi
echo $USERNAME

OS=$(uname)
if [ "$OS" = "Darwin" ]; then
	HOMEDIR=/Users/$USERNAME
elif [ "$OS" = "Linux" ]; then
	HOMEDIR=/home/$USERNAME
else
	echo "unsupported OS: $OS"
	exit 1
fi

# Symlink home-manger to the config directory
ln -s ~/nixhome/home-manager ~/.config/home-manager

# Set the default shell to fish
echo "changing shell authentication to 'sufficient' in pam.d/chsh"
sudo sed -i 's/required/sufficient/g' /etc/pam.d/chsh

echo "adding fish shell to shellenv"
sudo sh -c 'printf "%s\n" '"$HOMEDIR"'/.nix-profile/bin/fish >> /etc/shells'

echo "setting default shell to fish"
sudo chsh -s $HOMEDIR/.nix-profile/bin/fish $USERNAME

if [ "$OS" = "Darwin" ]; then
	if ! command -v brew >/dev/null 2>&1; then
		echo "installing Homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	echo "installing Homebrew packages from Brewfile"
	brew bundle --file ~/nixhome/Brewfile

	echo "applying macOS system defaults"
	defaults write com.apple.screencapture location -string "~/Screenshots"
	defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
	defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
	defaults write com.apple.WindowManager EnableStandardWindowDragging -bool true
	defaults write com.apple.CrashReporter DialogType -string "none"
	defaults write com.apple.dock autohide-delay -float 0
	defaults write com.apple.dock autohide-time-modifier -float 0.1
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true
	defaults write com.apple.finder AppleShowAllFiles -bool true
	defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
	defaults write NSGlobalDomain KeyRepeat -int 1
	defaults write NSGlobalDomain InitialKeyRepeat -int 15
	killall SystemUIServer
	killall Dock
fi

echo "setup complete, restart your terminal to activate the fish shell, or run command `fish`"
