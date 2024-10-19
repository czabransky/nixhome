# Nix Installation

```sh
# Install Nix with Flakes enabled
sh <(curl -L https://nixos.org/nix/install) --no-daemon ;
mkdir -p ~/.config/nix ;
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf ;

# Restart your shell so the nix command is available
# nix shell is used to run git whether it's installed on the host or not
# Install nix home-manager and symlink my home.nix flake
# Modify flake.nix "colin" to your username
# Modify home.nix "colin" to your username
nix shell nixpkgs#git --command nix flake clone github:czabransky/nixhome --dest ~/dotfiles ;
nix run home-manager/master -- init --switch ;
rm -rf ~/.config/home-manager ;
ln -s ~/dotfiles/home-manager ~/.config/home-manager ;
sed -i 's/colin/<your-user-name>/g' ~/dotfiles/home-manager/flake.nix
sed -i 's/colin/<your-user-name>/g' ~/dotfiles/home-manager/home.nix

# Run home-manager to install packages and symlink the remaining configuration files
home-manager --impure switch

# Run the setup.sh to add fish as your default shell
/bin/bash ~/dotfiles/setup.sh <your-user-name>
```
