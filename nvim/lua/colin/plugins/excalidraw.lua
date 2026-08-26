-- https://github.com/czabransky/excalidraw.nvim
-- Fork of marcocofano/excalidraw.nvim with:
-- - a fix for scenes serializing "files": [] instead of "files": {},
--   which strict native clients like ExcalidrawZ reject outright
--   (commit befd7d5)
-- - `open -n` on macOS, working around ExcalidrawZ not loading the file
--   when it's already running (commit 10315a0) - drop -n once
--   https://github.com/chocoford/ExcalidrawZ fixes that; create/find_scenes
--   nag about this on every run as a reminder to check
-- - a standalone :Excalidraw insert_link command (was previously only
--   reachable as the <C-l> alt-mapping inside the find_scenes picker)
--
-- Opens .excalidraw links (markdown links or bare paths) in the system's
-- default app for that file type - point that association at ExcalidrawZ
-- (or an installed excalidraw.com PWA) via Finder > Get Info > Open With.
return {
	"czabransky/excalidraw.nvim",
	dependencies = { "nvim-telescope/telescope.nvim" },
	cmd = "Excalidraw",
	keys = {
		-- README prose says ":Excalidraw open" but the registered
		-- subcommand (see lua/excalidraw/commands/commands.lua) is
		-- actually "open_link".
		{ "<leader>Do", "<cmd>Excalidraw open_link<cr>", desc = "Open Link" },
		{ "<leader>Dc", "<cmd>Excalidraw create<cr>", desc = "Create Scene" },
		{ "<leader>Dt", "<cmd>Excalidraw create_from_template<cr>", desc = "Create From Template" },
		{ "<leader>Df", "<cmd>Excalidraw find_scenes<cr>", desc = "Find Scenes" },
		{ "<leader>Db", "<cmd>Excalidraw find_scenes_in_buffer<cr>", desc = "Find Scenes In Buffer" },
		{ "<leader>Di", "<cmd>Excalidraw insert_link<cr>", desc = "Insert Link" },
	},
	config = function()
		require("excalidraw").setup({})
	end,
}
