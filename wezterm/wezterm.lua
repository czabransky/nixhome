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
	end)
}
