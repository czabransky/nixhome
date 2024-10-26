# What is this Project?

This is a [nix](https://nixos.org/) and [nix home-manager](https://github.com/nix-community/home-manager) driven dotfiles configuration for linux-based systems. With only a few commands your linux system will install a number of commonly used tools all while configuring them with my preferred settings.  

Feel free to choose whatever terminal applciation you like - this configuration is using the `tokyonight` theme.

# Installation
## Linux

```sh
# install nix with flakes enabled
sh <(curl -L https://nixos.org/nix/install) --no-daemon ;
mkdir -p ~/.config/nix ;
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf ;

# restart your shell so the nix command is available
# nix shell is used to run git whether it's installed on the host or not
# !! -> update the commands below and replace <your-user-name>
nix shell nixpkgs#git --command nix flake clone github:czabransky/nixhome --dest ~/nixhome ;
nix run home-manager/master -- init --switch ;
rm -rf ~/.config/home-manager ;
ln -s ~/nixhome/home-manager ~/.config/home-manager ;
sed -i 's/colin/<your-user-name>/g' ~/nixhome/home-manager/flake.nix ;
sed -i 's/colin/<your-user-name>/g' ~/nixhome/home-manager/home.nix ;

# run home-manager to install packages and symlink the remaining configuration files
home-manager --impure switch

# run the setup.sh to add fish as your default shell
/bin/bash ~/nixhome/setup.sh <your-user-name>
```

### Tmux Plugins

```sh
# for tmux plugins to install automatically, install the plugin manager first
mkdir -p ~/.config/tmux/plugins ;
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm ;
```
With tmux running: 
- install plugins: `ctrl+a + I`
- reload: `ctrl+a + R`

## Windows
> [!NOTE]
>	OneDrive users beware, your powershell $profile points to OneDrive/Documents.
>   You may need to modify the script below or manually copy the powershell profile to the correct location.
>   Personally, I uninstalled OneDrive and modified keys in:
>   `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders`

1. Install Git
```pwsh 
winget install --id Git.Git
```
2. Install Scoop
```pwsh
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```
3. Install Scoop Packages:
```pwsh
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
```

```
4. Run `setup.ps1` script to configure powershell, wezterm, and neovim.

> [!TIP] Update Powershell to 7+  
```pwsh
# Check powershell version: $PSVersionTable  
# Update powershell with winget:  
winget search Microsoft.PowerShell
winget install --id Microsoft.PowerShell --source winget
```

# Neovim

Launching neovim (aliased to `n`) will automatically install its plugins using the [Lazy Plugin Manager](https://github.com/folke/lazy.nvim).
- Run `:checkhealth` to validate your configuration.

## Keybinds

Here are a few notable keybinds to help you get started.

- Note: The `<leader>` key is mapped to `<SPACE>`
- Pressing the `<leader>` key will open the `whichkey` display after a moment.
- `<leader>tt` will open the `nvimtree` explorer. With the exporer open, `g?` will show available keybinds. 
- `<leader>sf` will open the `telescope` file search. Type the name of the file you want to open.
- `<leader>st` will open the `telescope.builtin` menu, where you can find tons of helpful info.
- `<leader>sc` will open the `commands` menu, which lists available commands in a fuzzy finder.
- `<leader>sh` will open the `help` search menu, where you can search on all things neovim.
