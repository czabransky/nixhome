# What is this Project?

This is a [nix](https://nixos.org/) and [nix home-manager](https://github.com/nix-community/home-manager) driven dotfiles configuration for linux-based systems. With only a few commands your linux system will install a number of commonly used tools all while configuring them with my preferred settings.  

Feel free to choose whatever terminal applciation you like - this configuration is using the `tokyonight` theme.

# Nix Installation

```sh
# install nix with flakes enabled
sh <(curl -L https://nixos.org/nix/install) --no-daemon ;
mkdir -p ~/.config/nix ;
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf ;

# restart your shell so the nix command is available
# nix shell is used to run git whether it's installed on the host or not
# !! -> update the commands below and replace <your-user-name>
nix shell nixpkgs#git --command nix flake clone github:czabransky/nixhome --dest ~/dotfiles ;
nix run home-manager/master -- init --switch ;
rm -rf ~/.config/home-manager ;
ln -s ~/dotfiles/home-manager ~/.config/home-manager ;
sed -i 's/colin/<your-user-name>/g' ~/dotfiles/home-manager/flake.nix ;
sed -i 's/colin/<your-user-name>/g' ~/dotfiles/home-manager/home.nix ;

# run home-manager to install packages and symlink the remaining configuration files
home-manager --impure switch

# run the setup.sh to add fish as your default shell
/bin/bash ~/dotfiles/setup.sh <your-user-name>
```

# Tmux Plugins

```sh
# For tmux plugins to install automatically, we need to install the plugin manager first
mkdir -p ~/.config/tmux/plugins ;
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm ;
```
With tmux running: 
- install plugins: `ctrl+a + I`
- reload: `ctrl+a + R`


# Neovim

Launching neovim (aliased to `n`) will automatically install its plugins using the [Lazy Plugin Manager](https://github.com/folke/lazy.nvim).
- Run `:checkhealth` to validate your configuration.

## Keybinds

Here are a few notable keybindts to help you get started.

- Note: The `<leader>` key is mapped to `<SPACE>`
- Pressing the <leader> key will open the `whichkey` display after a moment.
- `<leader>tt` will open the `nvimtree` explorer. With the exporer open, `g?` will show available keybinds. 
- `<leader>sf` will open the `telescope` file search. Type the name of the file you want to open.
- `<leader>st` will open the `telescope.builtin` menu, where you can find tons of helpful info.
- `<leader>sc` will open the `commands` menu, which lists available commands in a fuzzy finder.
- `<leader>sh` will open the `help` search menu, where you can search on all things neovim.
