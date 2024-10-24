# ------------------------------
# Installation of Dependencies
## if you want to use neovim as an editor you'll need a neovim config as well
## if you want tmux-like features you can install wezterm
# ------------------------------
<#
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

scoop install ripgrep ;
scoop install fd ;
scoop install fzf ;
scoop install bat ;
scoop install zoxide ;
scoop install glow ;

scoop install mingw ;
scoop install neovim ;

scoop bucket add extras ;
scoop install wezterm ;

#>

$Env:EDITOR = "nvim"
$Env:BAT_THEME = "Nord"

Set-Location $HOME

Set-Alias -Name l -Value ls
Set-Alias -Name lg -Value lazygit
Set-Alias -Name g -Value glow
Set-Alias -Name n -Value nvim
Invoke-Expression (& { (zoxide init powershell | Out-String) })


# Select an entry from zoxide using fzf
function zz {
	param (
		$f
	)
	$dir = zoxide query --list $f | fzf --ansi --border --reverse
	z $dir
}

# Remove the selected entry from zoxide
function zd {
	param (
		$f
	)
	$dir = zoxide query --list $f | fzf --ansi --border --reverse
	zoxide remove $dir
	echo "$dir removed from zoxide"
}


function gitaudit {
	param (
		$f
	)
	git log --pretty=format:%H -- $f | fzf --ansi --border --reverse `
		--preview "git log -p -1 {} $f | bat -n --color=always" `
		--preview-window=right,70% `
		--bind ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up
}

Set-PSReadLineKeyHandler -Chord Ctrl+u -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
}

Set-PSReadLineKeyHandler -Chord Ctrl+p -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("cd ..")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

Set-PSReadLineKeyHandler -Chord Ctrl+z -ScriptBlock {
	$result = ( zoxide query --list | fzf --ansi --border --reverse --preview 'fd {}')
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("" + $result)
}

Set-PSReadLineKeyHandler -Chord Ctrl+f -ScriptBlock {
	$result = ( fd -t f | fzf --ansi --border --reverse --preview 'bat -n --color=always --line-range :500 {}')
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("" + $result)
}

Set-PSReadLineKeyHandler -Chord Alt+c -ScriptBlock {
	$result = ( fd -t d | fzf --ansi --border --reverse --preview 'fd -t f . {}')
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("" + $result)
}

Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
	$cmd = cat (Get-PSReadlineOption).HistorySavePath | fzf --ansi --border --reverse
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("" + $cmd)
}
