<#
One-command machine bootstrap for Windows. Safe to re-run.

  irm https://raw.githubusercontent.com/czabransky/nixhome/main/setup.ps1 | iex

Installs Git and Scoop (if needed), installs all Scoop packages, clones this
repo (if needed), and configures powershell, wezterm, vim/ideavim, neovim,
yazi, git/delta/lazygit, and Claude Code settings. Pass -UseKomorebi to also
install and configure Komorebi + whkd.
#>
param (
    [Switch]$UseKomorebi
)

$RepoDir = "$HOME\nixhome"

# Allow running local scripts for this user (needed for Scoop, and for
# re-running this script directly after it's cloned)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Install Git if it isn't already available (needed to clone this repo)
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Output "installing git"
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements

    # refresh this session's PATH so `git` is usable without restarting
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Clone this repo if it isn't already present
if (-not (Test-Path $RepoDir)) {
    Write-Output "cloning nixhome"
    git clone https://github.com/czabransky/nixhome.git $RepoDir
}

# Install Scoop if it isn't already available
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Output "installing scoop"
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

Write-Output "installing scoop packages"
scoop bucket add nerd-fonts
scoop bucket add extras
scoop install RobotoMono-NF
scoop install ripgrep file fd eza fzf bat zoxide mingw
scoop install lazygit delta
scoop install yazi glow
scoop install neovim vcredist2022
scoop install wezterm

if ($UseKomorebi) {
    scoop install komorebi whkd
}

# Copy into Powershell 5 and 6+ locations
$psroot = [System.IO.Path]::GetDirectoryName("$profile")

[System.IO.Directory]::CreateDirectory($psroot)
cp $RepoDir/powershell/Microsoft.Powershell_profile.ps1 $profile

if (![System.IO.File]::Exists("$psroot/custom.ps1"))
{
    cp $RepoDir/powershell/custom.ps1 $psroot
}

# Configure komorebi
if ($UseKomorebi)
{
    Write-Output "Copying Komorebi files because Use Komorebi flag is enabled."
    if (Test-Path $HOME/.config/komorebi) {
        rm -Recurse $HOME/.config/komorebi
    }
    cp -Recurse $RepoDir/komorebi $HOME/.config/komorebi
    cp $RepoDir/komorebi/applications.json $HOME

    # Configure whkd
    if (Test-Path $HOME/.config/whkd) {
        rm -Recurse $HOME/.config/whkd
    }
    cp -Recurse $RepoDir/whkd $HOME/.config/whkd
}

# Configure Yazi
if (Test-Path $HOME/.config/yazi) {
    rm -Recurse $HOME/.config/yazi
}
cp -Recurse $RepoDir/yazi $HOME/.config/yazi

# Configure Wezterm
cp $RepoDir/wezterm/wezterm.lua $HOME/.wezterm.lua

# Configure Vim
cp $RepoDir/vim/vimrc $HOME/.vimrc
cp $RepoDir/ideavim/ideavimrc $HOME/.ideavimrc

if (Test-Path $HOME/.config/nvim) {
    rm -Recurse $HOME/.config/nvim
}
cp -Recurse $RepoDir/nvim $HOME/.config/nvim

# Configure Claude Code
[System.IO.Directory]::CreateDirectory("$HOME/.claude")
cp $RepoDir/claude/settings.json $HOME/.claude/settings.json

# Layer this repo's git/delta config on top of whatever's already in
# ~/.gitconfig (user.name, credential helpers, etc.) without touching it
$gitConfigNix = "$RepoDir\git\config-nix"
$existingIncludes = git config --global --get-all include.path 2>$null
if (-not ($existingIncludes -contains $gitConfigNix)) {
    git config --global --add include.path $gitConfigNix
}

# Configure Lazygit (delta pager is inert on Windows, but harmless to set)
$lazygitConfigDir = "$env:LOCALAPPDATA\lazygit"
[System.IO.Directory]::CreateDirectory($lazygitConfigDir)
cp $RepoDir/git/lazygit-config.yml "$lazygitConfigDir/config.yml"

# Source the profile to update the current shell
. $profile

Write-Output "setup complete!"
