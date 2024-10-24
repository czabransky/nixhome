<#

 Windows Setup
	 1. Install Scoop

		Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
		Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

	 2. Install Scoop Packages:
		
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

