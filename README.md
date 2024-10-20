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
