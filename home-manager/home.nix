{ config, pkgs, lib, ... }:
let
  # Machine-local work identity, kept out of this repo. When present it enables
  # the work profile. Shape:
  #   { name = "acme"; email = "me@acme.com"; githubUser = "me-acme"; }
  # `name` is the directory under ~/code (and ~/.herdr/worktrees) that is work.
  # `githubUser` is optional.
  workFile = ~/.config/nixhome-local/work.nix;
  work = if builtins.pathExists workFile then import workFile else null;
  workRepo = "code/${work.name}";
  workWorktrees = ".herdr/worktrees/${work.name}";
in
{
  home.username = "colin";
  home.homeDirectory = "/Users/colin";
  home.stateVersion = "26.05";

  # The home.packages option allows you to install Nix packages.
  # https://search.nixos.org/packages
  home.packages = [
    pkgs.bat
    pkgs.bws
    pkgs.colima
    pkgs.curl
    pkgs.delta
    pkgs.docker
    pkgs.docker-compose
    pkgs.eza
    pkgs.fd
    pkgs.file
    pkgs.fish
    pkgs.fzf
    pkgs.gh
    pkgs.git
    pkgs.jq
    pkgs.lazydocker
    pkgs.lazygit
    pkgs.neovim
    pkgs.netcoredbg
    pkgs.nixfmt
    pkgs.nodejs_22
    pkgs.nushell
    pkgs.pnpm
    pkgs.postgresql_16
    pkgs.ripgrep
    pkgs.starship
    pkgs.tree-sitter
    pkgs.unzip
    pkgs.yazi
    pkgs.zoxide
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
    ".config/nushell" = {
      source = ~/nixhome/nushell;
      recursive = true;
    };
    ".claude/settings.json".source = ~/nixhome/claude/settings.json;
    ".claude/CLAUDE.md".source = ~/nixhome/claude/CLAUDE.md;
    ".homebrew/Brewfile".source = ~/nixhome/homebrew/Brewfile;
  }
  // lib.optionalAttrs (work != null) {
    # Work profile: same Claude settings, separate login/MCP/memory, selected
    # per-directory by direnv (see direnv/work.envrc).
    ".claude-work/settings.json".source = ~/nixhome/claude/settings.json;
    ".claude-work/CLAUDE.md".source = ~/nixhome/claude/CLAUDE.md;
    "${workRepo}/.envrc".source = ~/nixhome/direnv/work.envrc;
    "${workWorktrees}/.envrc".source = ~/nixhome/direnv/work.envrc;
    # Git reads this alongside ~/.gitconfig; worktrees keep their gitdir under
    # the main repo's .git, so they match too.
    ".config/git/config".text = ''
      [includeIf "gitdir:~/${workRepo}/"]
      	path = ~/.config/git/work
    '';
    ".config/git/work".text = ''
      [user]
      	email = ${work.email}
    '' + lib.optionalString (work ? githubUser) ''
      [credential "https://github.com"]
      	username = ${work.githubUser}
    '';
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  }
  // lib.optionalAttrs (work != null) {
    # Pre-approve the work .envrc files so they load without `direnv allow`.
    config.whitelist.prefix = [
      "${config.home.homeDirectory}/${workRepo}"
      "${config.home.homeDirectory}/${workWorktrees}"
    ];
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
    VISUAL = "nvim";
    NVIM_APPNAME = "nvim";
  };

}
