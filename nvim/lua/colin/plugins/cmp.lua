local M = {}

function M.blinkcmp()
	return {
		"saghen/blink.cmp",
		lazy = false,
		dependencies = { "rafamadriz/friendly-snippets" },
		version = "1.*",
		opts = {
			keymap = {
				preset = "default",
				-- Some terminals send <C-Space> as <C-@>.
				["<C-Space>"] = { "select_and_accept", "show", "show_documentation", "hide_documentation" },
				["<C-@>"] = { "select_and_accept", "show", "show_documentation", "hide_documentation" },
				["<CR>"] = { "accept", "fallback" },
			},
			appearance = {
				nerd_font_variant = "normal",
			},
			completion = {
				list = {
					selection = {
						preselect = true,
						auto_insert = false,
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 250,
				},
				ghost_text = {
					enabled = true,
				},
			},
			signature = {
				enabled = true,
			},
			fuzzy = {
				implementation = "prefer_rust_with_warning",
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
		},
		opts_extend = { "sources.default" },
	}
end

return M
