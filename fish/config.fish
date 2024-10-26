# Disable fish greeting
set -U fish_greeting

# Ensure nix packages are available in $PATH
fish_add_path --path $HOME/.nix-profile/bin
set -qU XDG_CONFIG_HOME; or set XDG_CONFIG_HOME $HOME/.config
set -qU XDG_DATA_HOME; or set XDG_DATA_HOME $HOME/.local/share
set -qU XDG_CACHE_HOME; or set XXDG_CACHE_HOME $HOME/.cache

# Initialize shell packages
starship init fish | source
zoxide init fish | source

# Configure default editors
set -gx EDITOR nvim
set -gx VISUAL code

# Change default starting directory
cd $HOME
