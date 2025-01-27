$Env:BAT_THEME = "Nord"
$Env:EDITOR = "nvim"
$Env:KOMOREBI_CONFIG_HOME = "$HOME/.config/komorebi"
$Env:WHKD_CONFIG_HOME = "$HOME/.config/whkd"
$Env:XDG_CONFIG_HOME = "$HOME/.config"
$Env:YAZI_CONFIG_HOME = "$HOME/.config/yazi"
$Env:NOTES_HOME = "$HOME/.config/notes"

Invoke-Expression (& { (zoxide init powershell | Out-String) })
Set-Alias -Name g -Value glow
Set-Alias -Name lg -Value lazygit
Set-Alias -Name n -Value nvim
Set-Alias -Name ns -Value nvimsession

# Use fd by default to query directories
# This function will not work well when trying to pass a path argument, e.g,
# l $HOME/Documents
# This is because Windows likes to tab-complete paths using backslashes \ which fd does not interpret well.
# `ls` works fine for listing a different directory than your current directory.
function l
{
    fd -tf -td -H -d1 --exclude 'ntuser*' --exclude 'NTUSER*'
}

# Select an entry from zoxide using fzf
function zz
{
    param (
        $f
    )
    $dir = zoxide query --list $f | fzf --ansi --border --reverse
    z $dir
}

# Remove the selected entry from zoxide
function zd
{
    param (
        $f
    )
    $dir = zoxide query --list $f | fzf --ansi --border --reverse
    zoxide remove $dir
    Write-Output "$dir removed from zoxide"
}

# Yazi shell wrapper that provides the ability to change the current working directory when exiting Yazi.
function y
{
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path)
    {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}

# Open the git remote url in Chrome
function gitbrowse
{
    Start-Process chrome $(git config --get remote.origin.url)
}

# Audit a file in git to see its change history. Alternative UI: gitk $file
function gitaudit
{
    param (
        $f
    )
    git log --pretty=format:%H -- $f | fzf --ansi --border --reverse `
        --preview "git log -p -1 {} $f | bat -n --color=always" `
        --preview-window=right,70% `
        --bind ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up

}

function nlinks
{
    n "$Env:NOTES_HOME/Links.md"
}

function links
{
    glow -w 200 "$Env:NOTES_HOME/Links.md"
}


# Restart Komorebi
function komorebi-restart
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$ConfigPath
    )
    taskkill /im komo* /f
    komorebic start --whkd --bar --config $ConfigPath
}

# Launch firefox to Lofi beats!
function lofi
{
    firefox -new-tab "https://www.youtube.com/watch?v=jfKfPfyJRdk"
}

function Get-DefaultBrowser {
    # Get the default browser's ProgId from the registry
    $progId = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice').ProgId

    # Get the command associated with the ProgId using the full registry path
    $browserPath = (Get-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\$progId\shell\open\command").'(Default)'

    # Extract the browser executable path (handling paths with spaces)
    # Use regex to match the quoted path
    if ($browserPath -match '"(.*?)"') {
        $defaultBrowser = $matches[1]
    } else {
        # Fallback: If no quotes are found, split and take the first part
        $defaultBrowser = ($browserPath -split ' ')[0]
    }

    # Return the default browser path
    return $defaultBrowser
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

# Alt+f to expand links and add them to your current command
Set-PSReadLineKeyHandler -Chord Alt+f -ScriptBlock {
    $result = ( links | fzf `
            --ansi --border --reverse `
            --bind ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up
    )
    if ($result -match '(https?://[^\s]+)')
    {
        $uri = $matches[1]
        $defaultBrowser = Get-DefaultBrowser
        echo 'browser: ' + $defaultBrowser
        $process = Start-Process -FilePath "$defaultBrowser" -ArgumentList $uri -PassThru
        $hwnd = $process.MainWindowHandle
        [User32]::SetForegroundWindow($hwnd)
    }
}

# Alt+c to expand directory names to your current command
Set-PSReadLineKeyHandler -Chord Alt+c -ScriptBlock {
    $result = ( fd -t d -H | fzf --ansi --border --reverse `
            --walker-skip .git,node_modules,target `
            --preview 'fd -t f . {}' `
            --preview-window=right,60% `
            --bind ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up
    )
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("" + $result)
}

# Ctrl+r to show a command history
Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    $cmd = Get-Content (Get-PSReadlineOption).HistorySavePath | fzf --ansi --border --reverse --tac
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("" + $cmd)
}

# Define the SetForegroundWindow function from user32.dll
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class User32 {
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

# Source user-specific configurations
. $PSScriptRoot\custom.ps1

