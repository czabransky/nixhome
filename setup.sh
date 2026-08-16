#!/bin/bash
#
# One-command machine bootstrap for macOS and Linux. Safe to re-run.
#
#   sh <(curl -fsSL https://raw.githubusercontent.com/czabransky/nixhome/main/setup.sh)
#
# Installs nix, enables flakes, clones this repo (if needed), runs
# home-manager, sets fish as the default shell, and (on macOS) installs
# Homebrew + this repo's Brewfile and applies macOS system defaults.

USERNAME=${1:-$USER}
REPO_DIR="$HOME/nixhome"

echo "provisioning for $USERNAME"

OS=$(uname)
case "$OS" in
	Darwin) HOMEDIR="/Users/$USERNAME" ;;
	Linux) HOMEDIR="/home/$USERNAME" ;;
	*)
		echo "unsupported OS: $OS"
		exit 1
		;;
esac

# Install nix (single-user) if it isn't already available
if ! command -v nix >/dev/null 2>&1; then
	echo "installing nix"
	sh <(curl -L https://nixos.org/nix/install) --no-daemon
fi

# Make nix available in this shell without requiring a restart
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
	. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
	. "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# nix-command and flakes are still gated behind experimental-features
mkdir -p ~/.config/nix
grep -qxF 'experimental-features = nix-command flakes' ~/.config/nix/nix.conf 2>/dev/null ||
	echo 'experimental-features = nix-command flakes' >>~/.config/nix/nix.conf

# Clone this repo if it isn't already present
if [ ! -d "$REPO_DIR" ]; then
	echo "cloning nixhome"
	nix shell nixpkgs#git --command nix flake clone github:czabransky/nixhome --dest "$REPO_DIR"
fi

# Bootstrap the home-manager CLI itself the first time only
if ! command -v home-manager >/dev/null 2>&1; then
	echo "bootstrapping home-manager"
	nix run home-manager/master -- init --switch
fi

# Point home-manager at this repo's config, and rename the profile to this user
mkdir -p ~/.config
if [ "$(readlink "$HOME/.config/home-manager")" != "$REPO_DIR/home-manager" ]; then
	rm -rf ~/.config/home-manager
	ln -s "$REPO_DIR/home-manager" ~/.config/home-manager
fi
sed -i 's/colin/'"$USERNAME"'/g' "$REPO_DIR/home-manager/flake.nix"
sed -i 's/colin/'"$USERNAME"'/g' "$REPO_DIR/home-manager/home.nix"

echo "running home-manager switch"
home-manager --impure switch -b backup

# Layer this repo's git/delta config on top of whatever's already in
# ~/.gitconfig (user.name, credential helpers, etc.) without touching it
git config --global --get-all include.path 2>/dev/null | grep -qxF "$REPO_DIR/git/config-nix" ||
	git config --global --add include.path "$REPO_DIR/git/config-nix"

# Set the default shell to fish
echo "changing shell authentication to 'sufficient' in pam.d/chsh"
sudo sed -i 's/required/sufficient/g' /etc/pam.d/chsh

echo "adding fish shell to shellenv"
grep -qxF "$HOMEDIR/.nix-profile/bin/fish" /etc/shells 2>/dev/null ||
	sudo sh -c 'printf "%s\n" '"$HOMEDIR"'/.nix-profile/bin/fish >> /etc/shells'

echo "setting default shell to fish"
sudo chsh -s "$HOMEDIR/.nix-profile/bin/fish" "$USERNAME"

if [ "$OS" = "Darwin" ]; then
	if ! command -v brew >/dev/null 2>&1; then
		echo "installing Homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	echo "installing Homebrew packages from ~/.homebrew/Brewfile"
	brew bundle --file ~/.homebrew/Brewfile

	echo "applying macOS system defaults"
	chflags nohidden ~/Library
	defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
	defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true
	defaults write NSGlobalDomain InitialKeyRepeat -int 15
	defaults write NSGlobalDomain KeyRepeat -int 1
	defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
	defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
	defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
	defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
	defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
	defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
	defaults write com.apple.ActivityMonitor ShowCategory -int 0
	defaults write com.apple.CrashReporter DialogType -string "none"
	defaults write com.apple.WindowManager EnableStandardWindowDragging -bool true
	defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
	defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
	defaults write com.apple.dock autohide-delay -float 0
	defaults write com.apple.dock autohide-time-modifier -float 0.1
	defaults write com.apple.finder AppleShowAllFiles -bool true
	defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
	defaults write com.apple.finder _FXSortFoldersFirst -bool true
	defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
	defaults write com.apple.menuextra.battery ShowPercent -bool true
	defaults write com.apple.menuextra.clock ShowSeconds -bool true
	defaults write com.apple.screencapture location -string "~/Screenshots"
	defaults write com.apple.screensaver askForPassword -int 1
	defaults write com.apple.screensaver askForPasswordDelay -int 0
	killall SystemUIServer
	killall Dock
	killall Finder
fi

echo "setup complete! restart your terminal to activate the fish shell, or run: fish"
