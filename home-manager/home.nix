{ config, pkgs, ... }:
{
	home.username = "colin";
	home.homeDirectory = "/home/colin";
	home.stateVersion = "24.05"; 

# The home.packages option allows you to install Nix packages.
# https://search.nixos.org/packages
	home.packages = [
			pkgs.fish
			pkgs.starship
			pkgs.curl
			pkgs.git
			pkgs.lazygit
			pkgs.ripgrep
			pkgs.fzf
			pkgs.fd
			pkgs.bat
			pkgs.eza
			pkgs.zoxide
			pkgs.jq
			pkgs.tmux
			pkgs.neovim
	];

# Home Manager is pretty good at managing dotfiles. 
# These files will be symlinked in the user /home/ directory.
	home.file = {
		".vimrc".source = ~/dotfiles/vimrc;
		".config/fish" = {
			source = ~/dotfiles/fish;
			recursive = true;
		};
		".config/starship.toml".source = ~/dotfiles/starship/starship.toml;
		".config/tmux/tmux.conf".source = ~/dotfiles/tmux/tmux.conf;
	};

# Home Manager can configure individual programs so long as a wrapper exists.
# Wrappers can be found here: https://nix-community.github.io/home-manager/options.xhtml
	programs.home-manager.enable = true;
	programs.bat.enable = true;
	programs.bat.config.theme = "catppuccin";
	programs.bat.themes = {
		catppuccin = {
			src = pkgs.fetchFromGitHub {
				owner = "catppuccin";
				repo = "bat"; 
				rev = "d2bbee4f7e7d5bac63c054e4d8eca57954b31471";
				sha256 = "sha256-x1yqPCWuoBSx/cI94eA+AWwhiSA42cLNUOFJl7qjhmw=";
			};
			file = "themes/Catppuccin Frappe.tmTheme";
		};
	};

	home.sessionVariables = {
		EDITOR = "nvim";
	};
}
