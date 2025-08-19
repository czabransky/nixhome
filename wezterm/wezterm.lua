local wezterm = require("wezterm")
local mux = wezterm.mux

return {

	-- color_scheme = "tokyonight_storm",
	-- color_scheme = "tokyonight_moon",
	color_scheme = "tokyonight_night",
	-- color_scheme = "Catppuccin Frappe",
	default_prog = { "pwsh.exe", "-NoLogo" },
	enable_tab_bar = true,
	font = wezterm.font({ family = "RobotoMono Nerd Font" }),
	window_decorations = "NONE | RESIZE",
	max_fps = 144,

	wezterm.on("gui-startup", function(_)
		local tab, _, window = mux.spawn_window({
			workspace = "coding",
			args = { "pwsh.exe", "-NoLogo" },
		})
		tab:set_title("coding")
		window:gui_window():maximize()
		mux.set_active_workspace("coding")
	end),

	-- follow tmux/nvim keybinds
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
	keys = {
		-- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
		{
			key = "a",
			mods = "LEADER|CTRL",
			action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }),
		},

		{
			key = "e",
			mods = "LEADER",
			action = wezterm.action.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Enter new name for tab" },
				}),
				action = wezterm.action_callback(function(window, _, line)
					-- line will be `nil` if they hit escape without entering anything
					-- An empty string if they just hit enter
					-- Or the actual line of text they wrote
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},

		{
			key = "n",
			mods = "LEADER",
			action = wezterm.action.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Enter name for new workspace:" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					-- line will be `nil` if they hit escape without entering anything
					-- An empty string if they just hit enter
					-- Or the actual line of text they wrote
					if line then
						window:perform_action(
							wezterm.action.SwitchToWorkspace({
								name = line,
							}),
							pane
						)
					end
				end),
			}),
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
		{
			key = "o",
			mods = "LEADER",
			action = wezterm.action.ShowLauncherArgs({
				flags = "FUZZY|WORKSPACES",
			}),
		},
	},
}
