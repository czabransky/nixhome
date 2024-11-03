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
			pkgs.unzip
			pkgs.xclip
			pkgs.gcc
			pkgs.git
			pkgs.lazygit
			pkgs.ripgrep
			pkgs.fzf
			pkgs.fd
			pkgs.jq
			pkgs.bat
			pkgs.eza
			pkgs.zoxide
			pkgs.file
			pkgs.yazi
			pkgs.tmux
			pkgs.glow
			pkgs.neovim
			pkgs.nodejs_22
			pkgs.dotnetCorePackages.sdk_8_0_4xx
	];

# Home Manager is pretty good at managing dotfiles. 
# These files will be symlinked in the user /home/ directory.
	home.file = {
		".vimrc".source = ~/nixhome/vim/vimrc;
		".config/fish" = {
			source = ~/nixhome/fish;
			recursive = true;
		};
		".config/starship.toml".source = ~/nixhome/starship/starship.toml;
		".config/yazi" = {
			source = ~/nixhome/yazi;
			recursive = true;
		};
		".config/tmux/tmux.conf".source = ~/nixhome/tmux/tmux.conf;
		".config/nvim" = {
			source = ~/nixhome/lazyvim;
			recursive = true;
		};
	};

# Home Manager can configure individual programs so long as a wrapper exists.
# Wrappers can be found here: https://nix-community.github.io/home-manager/options.xhtml
	programs.home-manager.enable = true;
	programs.bat.enable = true;
	programs.bat.config.theme = "tokyonight";
	programs.bat.themes = {
		tokyonight = {
			src = pkgs.fetchFromGitHub {
				owner = "enkia";
				repo = "enki-theme";
				rev = "0b629142733a27ba3a6a7d4eac04f81744bc714f";
				sha256 = "sha256-Q+sac7xBdLhjfCjmlvfQwGS6KUzt+2fu+crG4NdNr4w=";
			};
			file = "scheme/Enki-Tokyo-Night.tmTheme";
		};
	};

	home.sessionVariables = {
		EDITOR = "nvim";
	};
}
