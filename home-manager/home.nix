{ config, pkgs, ... }:
{
  home.username = "colin";
  home.homeDirectory = "/Users/colin";
  home.stateVersion = "26.05";

  # The home.packages option allows you to install Nix packages.
  # https://search.nixos.org/packages
  home.packages = [
    pkgs.fish
    pkgs.starship
    pkgs.curl
    pkgs.unzip
    pkgs.git
    pkgs.gh
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
    pkgs.delta
    pkgs.neovim
    pkgs.tree-sitter
    pkgs.nixfmt
    pkgs.docker
    pkgs.docker-compose
    pkgs.colima
    pkgs.lazydocker
    pkgs.nodejs_22
    pkgs.pnpm
    pkgs.postgresql_16
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
    ".config/herdr/config.toml".source = ~/nixhome/herdr/config.toml;
    ".config/nvim" = {
      source = ~/nixhome/nvim;
      recursive = true;
    };
    ".claude/settings.json".source = ~/nixhome/claude/settings.json;
    ".homebrew/Brewfile".source = ~/nixhome/homebrew/Brewfile;
  };

  # Home Manager can configure individual programs so long as a wrapper exists.
  # Wrappers can be found here: https://nix-community.github.io/home-manager/options.xhtml
  programs.home-manager.enable = true;
  programs.man.generateCaches = false;
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

  # Mirrors git/lazygit-config.yml, which is copied into place on Windows
  # since home-manager doesn't run there.
  programs.lazygit = {
    enable = true;
    settings = {
      gui.nerdFontsVersion = "3";
      git.pagers = [
        {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        }
      ];
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      		if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      		  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      		fi
      	  '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    NVIM_APPNAME = "nvim";
  };

}
