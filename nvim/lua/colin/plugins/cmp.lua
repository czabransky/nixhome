local M = {}

function M.blinkcmp()
	return {
		"saghen/blink.cmp",
		lazy = false,
		dependencies = { "rafamadriz/friendly-snippets" },
		version = "*",
		opts = {
			appearance = {
				nerd_font_variant = "normal",
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
		},
	}
end

return M
