# What is this Project?

This is a [nix](https://nixos.org/) and [nix home-manager](https://github.com/nix-community/home-manager) driven dotfiles configuration for linux-based systems. With only a few commands your linux system will install a number of commonly used tools all while configuring them with my preferred settings.  

Feel free to choose whatever terminal applciation you like - this configuration is using the `tokyonight` theme.

# Installation
## Linux
Install nix with flakes enabled.
```sh
sh <(curl -L https://nixos.org/nix/install) --no-daemon ;
mkdir -p ~/.config/nix ;
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf ;
```
Restart your shell so the nix command is available. The nix shell is used to run git whether it's installed on the host or not.
```sh
nix shell nixpkgs#git --command nix flake clone github:czabransky/nixhome --dest ~/nixhome ;
nix run home-manager/master -- init --switch ;
```
Configure home-manager symlink to git repository, and rename your nix profile to the current user.
```sh
rm -rf ~/.config/home-manager ;
ln -s ~/nixhome/home-manager ~/.config/home-manager ;
sed -i 's/colin/'"$USER"'/g' ~/nixhome/home-manager/flake.nix ;
sed -i 's/colin/'"$USER"'/g' ~/nixhome/home-manager/home.nix ;
```
Run home-manager to install packages and symlink the remaining configuration files.
```sh
home-manager --impure switch
```
Run `setup.sh` to add fish as your default shell.
```sh
/bin/bash ~/nixhome/setup.sh $USER
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

> [!TIP] 
> If you want to update powershell to version 7+: `winget install --id Microsoft.PowerShell --source winget`

Install Git
```pwsh 
winget install --id Git.Git
```
Install Scoop
```pwsh
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```
Install Scoop Packages:
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

Run `setup.ps1` script to configure powershell, wezterm, and neovim.


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
