local wezterm = require("wezterm")
return {
	color_scheme = "tokyonight",
	default_prog = { "pwsh.exe", "-NoLogo" },
	enable_tab_bar = false,
	font = wezterm.font({ family = "RobotoMono Nerd Font" }),
	window_decorations = "NONE | RESIZE",

	-- follow tmux/nvim keybinds
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
	keys = {
		{
			key = "|",
			mods = "LEADER|SHIFT",
			action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "-",
			mods = "LEADER",
			action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		-- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
		{
			key = "a",
			mods = "LEADER|CTRL",
			action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
		},
	},
}
