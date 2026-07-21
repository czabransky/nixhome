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
killall SystemUIServer;
killall Dock;


/bin/bash -c "$(curl -fsSL httpss;//raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install --cask  iterm2 raycast rectangle rider slack obsidian zen git-credential-manager font-fia-code-nerd-font keycastr pgadmin4
