# Working in this repo

This is a home-manager/Nix dotfiles repo (macOS + Linux) plus a PowerShell/Scoop
setup for Windows. See `README.md` for the full picture.

## Critical: `~/nixhome` is source, not the live config

`home.nix` uses `home.file."<path>" = { source = ~/nixhome/<dir>; recursive = true; }`
for `.vimrc`, `.config/fish`, `.config/starship.toml`, `.config/yazi`,
`.config/herdr/config.toml`, `.config/nvim`, `.claude/settings.json`, and
`.homebrew/Brewfile`. This makes home-manager symlink each file **individually**
into the Nix store at `home-manager switch` time — it is a build-time snapshot,
**not** a live/directory symlink back into this repo.

Consequence: editing a file under `~/nixhome` (e.g. `nvim/lua/...`) has **zero
effect** on the actual running config (`~/.config/nvim/...`) until
`home-manager switch` runs again. Don't assume an edit here is "deployed" —
verify by diffing, e.g.:

```sh
diff ~/.config/nvim/lua/colin/lsp/config/html.lua ~/nixhome/nvim/lua/colin/lsp/config/html.lua
```

if a deployed copy differs from the repo, the change isn't live yet.

**I run `home-manager switch` (and other nix commands) myself.** Don't run
`home-manager switch`, `nix run`, `setup.sh`, etc. on my behalf — just tell me
a switch is needed and let me do it. After I say I've run it, it's fine to
verify the deploy landed (e.g. the diff above) before testing further.

## Claude settings specifically: edit the repo copy, never the deployed one

`~/.claude/settings.json` is a symlink into the Nix store (deployed from
`~/nixhome/claude/settings.json` per the rule above). **Always edit
`~/nixhome/claude/settings.json`** — never `~/.claude/settings.json` or its
Nix store target. Same applies to any other file under `~/nixhome/claude/`.
Editing the deployed copy has no lasting effect (it's regenerated on the next
`home-manager switch`) and edits the wrong source of truth.

## nvim plugins are a separate layer again

`~/.local/share/nvim/lazy/*` (lazy.nvim's plugin checkouts) and
`~/.config/nvim/lazy-lock.json` are runtime state managed by lazy.nvim itself,
**not** by Nix/home-manager at all. Changing a plugin spec (e.g. a `branch =`
field in `nvim/lua/colin/plugins/*.lua`) only takes effect once:

1. `home-manager switch` has deployed the edited spec, **and**
2. lazy.nvim actually re-syncs that plugin (`:Lazy sync`, or headless
   `require("lazy").sync({ wait = true })`) — changing the spec alone doesn't
   move the git checkout.

## Windows side

`setup.ps1` doesn't use home-manager at all — it just `cp`s files from
`~\nixhome` directly into place (wezterm, nvim, yazi, vim/ideavim, Claude
settings, lazygit config). On Windows, edits to this repo likewise aren't live
until `setup.ps1` is re-run, but there's no Nix store involved — it's a plain
file copy.
