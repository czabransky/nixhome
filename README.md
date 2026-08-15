# What is this Project?

This is a [nix](https://nixos.org/) and [nix home-manager](https://github.com/nix-community/home-manager) driven dotfiles configuration for macOS and Linux, plus a PowerShell/Scoop driven setup for Windows. With only a few commands your machine will install a number of commonly used tools all while configuring them with my preferred settings.

Feel free to choose whatever terminal application you like - this configuration is using the `tokyonight` theme.

## Installation

### macOS / Linux

One command initializes the whole machine — installs nix, enables flakes, clones this repo to `~/nixhome`, runs home-manager, sets fish as the default shell, and (on macOS) installs Homebrew plus this repo's [`homebrew/Brewfile`](./homebrew/Brewfile) and applies a handful of system defaults. It's safe to re-run any time.

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/czabransky/nixhome/main/setup.sh)
```

- Defaults to your current `$USER`; pass a different name as an argument to override (`bash <(curl ...) someuser`).
- You'll be prompted for your password partway through (for the `chsh`/`pam.d` step, and on macOS if Homebrew needs installing).
- Once cloned, `~/nixhome/setup.sh` can also be run directly for future re-runs instead of the curl one-liner.

> [!NOTE]
> The flake resolves its `system` from `builtins.currentSystem`, so the same flake works unmodified on both aarch64-darwin and x86_64-linux — this, along with the `~`-relative paths in `home.nix`, is why `home-manager --impure switch` is required. `nix-command`/`flakes` are also still gated behind `experimental-features` on current stable Nix, so the script enables that explicitly too.

### Windows

> [!TIP]
> If you want to update powershell to version 7+: `winget install --id Microsoft.PowerShell --source winget`, but you will need to configure wezterm to use `pwsh`. Also, if you choose to install `Komorebi`, it is currently configured to use `pwsh` as well.

One command initializes the whole machine — installs Git and Scoop (if needed), installs all Scoop packages, clones this repo to `~\nixhome`, and configures powershell, wezterm, vim/ideavim, neovim, git/delta/lazygit, and Claude Code settings. It's safe to re-run any time.

```pwsh
irm https://raw.githubusercontent.com/czabransky/nixhome/main/setup.ps1 | iex
```

- Once cloned, `~\nixhome\setup.ps1` can also be run directly for future re-runs instead of the `irm` one-liner.

#### Tiling Window Manager

##### [Komorebi](https://lgug2z.github.io/komorebi/index.html)

> [!WARNING]
> Komorebi requires a commercial license for use at work.

Komorebi/whkd are opt-in and skipped by default because of the license restriction above. Re-run the already-cloned script locally with `-UseKomorebi` to install and configure them:

```pwsh
~\nixhome\setup.ps1 -UseKomorebi
## Default
komorebic start --whkd --bar
## Configuration when Primary Monitor is not Index 0
komorebic start --whkd --bar -c "$Env:USERPROFILE/.config/komorebi/komorebi.portable.json"
```

## Git, Delta & Lazygit

Git's pager/diff/merge settings and delta's theme live in one place, [`git/config-nix`](./git/config-nix), layered on top of whatever's already in `~/.gitconfig` via `include.path` — so existing `user.name`, `user.email`, and credential-helper settings are left untouched. The setup scripts wire this up automatically:

- macOS/Linux: `setup.sh` adds the `include.path` entry; `home.nix` installs `delta` and writes lazygit's config via `programs.lazygit.settings`.
- Windows: `setup.ps1` adds the same `include.path` entry and copies [`git/lazygit-config.yml`](./git/lazygit-config.yml) into place.

> [!WARNING]
> nvimdiff is crashing on exit when running within lazygit.

> [!NOTE]
> lazygit's delta pager is **not supported in lazygit on Windows** — it's configured there anyway for consistency, but silently ignored (no errors). lazygit may support pagers on Windows if [this PR is addressed](https://github.com/creack/pty/pull/155).
