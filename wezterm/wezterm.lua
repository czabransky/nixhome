local wezterm = require("wezterm")
return {
	color_scheme = "tokyonight",
	default_prog = { "pwsh.exe", "-NoLogo" },
	enable_tab_bar = false,
	font = wezterm.font({ family = "RobotoMono Nerd Font" }),
	-- window_decorations = "NONE | RESIZE",
}
