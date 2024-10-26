# Copy into Powershell 5 and 6+ locations
[System.IO.Directory]::CreateDirectory($HOME + '/Documents/WindowsPowerShell')
[System.IO.Directory]::CreateDirectory($HOME + '/Documents/PowerShell')
cp $HOME/nixhome/powershell/Microsoft.Powershell_profile.ps1 $HOME/Documents/WindowsPowerShell/ ;
cp $HOME/nixhome/powershell/Microsoft.Powershell_profile.ps1 $HOME/Documents/PowerShell/ ;

if (![System.IO.File]::Exists("$HOME/Documents/WindowsPowerShell/custom.ps1")) {
	cp $HOME/nixhome/powershell/custom.ps1 $HOME/Documents/WindowsPowerShell/ ;
}

if (![System.IO.File]::Exists("$HOME/Documents/PowerShell/custom.ps1")) {
	cp $HOME/nixhome/powershell/custom.ps1 $HOME/Documents/PowerShell/ ;
}

# Copy wezterm to $HOME directory
cp $HOME/nixhome/wezterm/wezterm.lua $HOME/.wezterm.lua ;

# Configure Neovim
cp $HOME/nixhome/vim/vimrc $HOME/.vimrc ;
rm -Recurse $HOME/.config/nvim
cp -Recurse $HOME/nixhome/nvim $HOME/.config/nvim

# Source the profile to update the current shell
. $profile
