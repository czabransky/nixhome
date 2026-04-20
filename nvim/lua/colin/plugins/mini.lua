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
		require("mini.surround").setup({
			mappings = {
				add = "ys",
				delete = "ds",
				replace = "cs",
				find = "sf",
				find_left = "sF",
				highlight = "sh",
				update_n_lines = "sn",
				suffix_last = "l",
				suffix_next = "n",
			},
		})
	end,
}
