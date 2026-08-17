-- mini.starter (part of mini.nvim, configured in plugins/mini.lua). Like
-- plugins/tree.lua, this exposes named alternatives; whichever one is called
-- from mini.lua's config is the active splash behavior.
local M = {}

-- No splash screen; mini.starter is simply never set up.
function M.none() end

local ascii_art = table.concat({
	" ███╗   ██╗██╗   ██╗██╗███╗   ███╗",
	" ████╗  ██║██║   ██║██║████╗ ████║",
	" ██╔██╗ ██║██║   ██║██║██╔████╔██║",
	" ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
	" ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
	" ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
}, "\n")

function M.splash()
	local starter = require("mini.starter")

	starter.setup({
		header = table.concat({ ascii_art, "", vim.fn.getcwd() }, "\n"),
		-- Every item name below starts with a different letter, so that with
		-- evaluate_single = true one keypress (no <CR>) runs the action.
		items = {
			{
				name = "Session",
				action = function()
					require("persistence").load()
				end,
				section = "Session",
			},
			{ name = "Find File", action = "Telescope find_files", section = "Builtin actions" },
			{ name = "Live Grep", action = "Telescope live_grep", section = "Builtin actions" },
			{ name = "Recent Files", action = "Telescope oldfiles", section = "Builtin actions" },
			{ name = "Explorer", action = "NvimTreeToggle", section = "Builtin actions" },
			{ name = "New File", action = "enew", section = "Builtin actions" },
			{ name = "Quit", action = "qa", section = "Builtin actions" },
		},
		content_hooks = {
			starter.gen_hook.adding_bullet(),
			starter.gen_hook.indexing("all", { "Builtin actions" }),
			starter.gen_hook.padding(3, 2),
			starter.gen_hook.aligning("center", "center"),
		},
		evaluate_single = true,
		footer = "",
	})
end

return M
