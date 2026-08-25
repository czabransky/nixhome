-- https://github.com/s1n7ax/nvim-window-picker
-- Overlays a big letter on every window and jumps to whichever you press -
-- same UX as nvim-tree's own internal window_picker. Needed as a global
-- (not flash.nvim-based) keymap because nvim-tree binds `s` itself
-- (system-open), which shadows flash's normal jump while focused there;
-- <leader>ww is a plain keymap nvim-tree never touches, so it works from
-- inside the tree too.
return {
	"s1n7ax/nvim-window-picker",
	event = "VeryLazy",
	config = function()
		require("window-picker").setup({
			hint = "floating-big-letter",
		})

		vim.keymap.set("n", "<leader>ww", function()
			local win = require("window-picker").pick_window()
			if win then
				vim.api.nvim_set_current_win(win)
			end
		end, { desc = "Window Picker" })
	end,
}
