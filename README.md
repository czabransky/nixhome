# Nix Installation

```sh
# Install Nix with Flakes enabled
sh <(curl -L https://nixos.org/nix/install) --no-daemon ;
mkdir -p ~/.config/nix ;
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf ;

# Restart your shell so the nix command is available
nix run home-manager/master -- init --switch;
rm -rf ~/.config/home-manager;
ln -s ~/dotfiles/home-manager ~/.config/home-manager
```
