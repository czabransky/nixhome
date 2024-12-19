local wezterm = require("wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
return {
	-- color_scheme = "tokyonight_storm",
	-- color_scheme = "tokyonight_moon",
	color_scheme = "tokyonight_night",
	default_prog = { "pwsh.exe", "-NoLogo" },
	enable_tab_bar = false,
	font = wezterm.font({ family = "RobotoMono Nerd Font" }),
	window_decorations = "NONE | RESIZE",
	max_fps = 144,

	-- follow tmux/nvim keybinds
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
	keys = {
		{
			key = "o",
			mods = "LEADER",
			action = workspace_switcher.switch_workspace(),
		},
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
		{
			key = "w",
			mods = "LEADER",
			action = wezterm.action.ShowLauncherArgs({
				flags = "FUZZY|WORKSPACES",
			}),
		},
	},
}
