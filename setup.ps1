param (
    [Switch]$SkipKomorebi
)

# Copy into Powershell 5 and 6+ locations
$psroot = [System.IO.Path]::GetDirectoryName("$profile")

[System.IO.Directory]::CreateDirectory($psroot)
cp $HOME/nixhome/powershell/Microsoft.Powershell_profile.ps1 $profile

if (![System.IO.File]::Exists("$psroot/custom.ps1")) {
	cp $HOME/nixhome/powershell/custom.ps1 $psroot
}

# Configure komorebi
if ($SkipKomorebi) {
    rm -Recurse $HOME/.config/komorebi
    cp -Recurse $HOME/nixhome/komorebi $HOME/.config/komorebi
    cp $HOME/nixhome/komorebi/applications.json $HOME
}

# Configure whkd
rm -Recurse $HOME/.config/whkd
cp -Recurse $HOME/nixhome/whkd $HOME/.config/whkd

# Configure Yazi
rm -Recurse $HOME/.config/yazi
cp -Recurse $HOME/nixhome/yazi $HOME/.config/yazi

# Configure Wezterm
cp $HOME/nixhome/wezterm/wezterm.lua $HOME/.wezterm.lua ;

# Configure Neovim
cp $HOME/nixhome/vim/vimrc $HOME/.vimrc ;
rm -Recurse $HOME/.config/nvim
cp -Recurse $HOME/nixhome/lazyvim $HOME/.config/nvim

# Source the profile to update the current shell
. $profile
