# Copy into Powershell 5 and 6+ locations
$psroot = [System.IO.Path]::GetDirectoryName("$profile")

[System.IO.Directory]::CreateDirectory($psroot)
cp $HOME/nixhome/powershell/Microsoft.Powershell_profile.ps1 $profile

if (![System.IO.File]::Exists("$psroot/custom.ps1")) {
	cp $HOME/nixhome/powershell/custom.ps1 $psroot
}


# Configure Yazi
rm -Recurse $HOME/.config/yazi
cp -Recurse $HOME/nixhome/yazi $HOME/.config/yazi

# Configure Wezterm
cp $HOME/nixhome/wezterm/wezterm.lua $HOME/.wezterm.lua ;

# Configure Neovim
cp $HOME/nixhome/vim/vimrc $HOME/.vimrc ;
rm -Recurse $HOME/.config/nvim
cp -Recurse $HOME/nixhome/nvim $HOME/.config/nvim


# Source the profile to update the current shell
. $profile
