$Env:XDG_CONFIG_HOME = "$HOME/.config"
$Env:YAZI_CONFIG_HOME = "$HOME/.config/yazi"
$Env:EDITOR = "nvim"
$Env:BAT_THEME = "Nord"

Set-Alias -Name lg -Value lazygit
Set-Alias -Name g -Value glow
Set-Alias -Name n -Value nvim
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Use fd by default to query directories
# This function will not work well when trying to pass a path argument, e.g,
# l $HOME/Documents
# This is because Windows likes to tab-complete paths using backslashes \ which fd does not interpret well.
# `ls` works fine for listing a different directory than your current directory.
function l {
	fd -tf -td -H -d1 --exclude 'ntuser*' --exclude 'NTUSER*'
}

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

# Yazi shell wrapper that provides the ability to change the current working directory when exiting Yazi.
function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}

# Audit a file in git to see its change history. Alternative UI: gitk $file
function gitaudit {
	param (
		$f
	)
	git log --pretty=format:%H -- $f | fzf --ansi --border --reverse `
		--preview "git log -p -1 {} $f | bat -n --color=always" `
		--preview-window=right,70% `
		--bind ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up
}

# Add standard shell key combo for clearing current buffer
Set-PSReadLineKeyHandler -Chord Ctrl+u -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
}

# Move up a directory with Ctrl+p
Set-PSReadLineKeyHandler -Chord Ctrl+p -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("cd ..")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# Ctrl+z to expand zoxide paths and add them to your current command
Set-PSReadLineKeyHandler -Chord Ctrl+z -ScriptBlock {
	$result = ( zoxide query --list | fzf --ansi --border --reverse --preview 'fd {}')
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("" + $result)
}

# Ctrl+f to expand file names into your current command
Set-PSReadLineKeyHandler -Chord Ctrl+f -ScriptBlock {
	$result = ( fd -t f -H | fzf --ansi --border --reverse `
		--preview 'bat -n --color=always --line-range :500 {}' `
		--preview-window=right,60% `
		--bind ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up
	)
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("" + $result)
}

# Alt+c to expand directory names to your current command
Set-PSReadLineKeyHandler -Chord Alt+c -ScriptBlock {
	$result = ( fd -t d -H | fzf --ansi --border --reverse `
		--preview 'fd -t f . {}' `
		--preview-window=right,60% `
		--bind ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up
	)
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("" + $result)
}

# Ctrl+r to show a command history
Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
	$cmd = cat (Get-PSReadlineOption).HistorySavePath | fzf --ansi --border --reverse
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("" + $cmd)
}

# Source user-specific configurations
. $PSScriptRoot\custom.ps1

