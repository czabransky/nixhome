return {
	"echasnovski/mini.nvim",
	version = "*",
	config = function()
		require("mini.animate").setup({
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
