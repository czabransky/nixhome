<#

 Windows Setup

	Note:	OneDrive users beware, your powershell $profile points to OneDrive/Documents.
			You may need to modify the script below or manually copy the powershell profile to the correct location.
			Personally, I uninstalled OneDrive and modified keys in:
				HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders

	 1. Install Git
		
		winget install --id Git.Git

	 2. Install Scoop

		Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
		Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

	 3. Install Scoop Packages:
		
		scoop install lazygit ;
		scoop install ripgrep ;
		scoop install fd ;
		scoop install fzf ;
		scoop install bat ;
		scoop install zoxide ;
		scoop install glow ;
		
		scoop install mingw ;
		scoop install neovim ;
		
		scoop bucket add nerd-fonts ;
		scoop install RobotoMono-NF ;

		scoop bucket add extras ;
		scoop install wezterm ;

	Optional: Update Powershell to 7+
		Check powershell version: $PSVersionTable
		Update powershell with winget: 
			winget search Microsoft.PowerShell
			winget install --id Microsoft.PowerShell --source winget

#>

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
