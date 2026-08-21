return {
	"echasnovski/mini.nvim",
	version = "*",
	config = function()
		local animate = require("mini.animate")
		animate.setup({
			-- Cursor/scroll animation is screen-share/pairing candy (lets
			-- viewers visually track jumps and scrolling) but distracting for
			-- solo work, so both start off and are toggleable below. resize
			-- always stays on - it's not a common-enough action to need one.
			cursor = {
				enable = false,
				timing = function(_, n)
					return 100 / n
				end,
			},
			scroll = {
				enable = false,
				timing = function(_, n)
					return 100 / n
				end,
			},
			resize = {
				enable = true,
				timing = function(_, n)
					return 100 / n
				end,
			},
		})

		vim.keymap.set("n", "<leader>cu", function()
			animate.config.cursor.enable = not animate.config.cursor.enable
		end, { desc = "[C]ode Toggle C[u]rsor Animation" })

		vim.keymap.set("n", "<leader>cs", function()
			animate.config.scroll.enable = not animate.config.scroll.enable
		end, { desc = "[C]ode Toggle [S]croll Animation" })
		require("mini.comment").setup()
		require("mini.pairs").setup()
		local hipatterns = require("mini.hipatterns")
		hipatterns.setup({
			highlighters = {
				hex_color = hipatterns.gen_highlighter.hex_color(),
			},
		})
		require("colin.plugins.starter").splash()
	end,
}
