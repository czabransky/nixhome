local wezterm = require 'wezterm'
return {
	default_prog = { 'pwsh.exe', '-NoLogo' },
	enable_tab_bar = false,
	font = wezterm.font { family = 'RobotoMono Nerd Font' },
	color_scheme = 'tokyonight'
}
