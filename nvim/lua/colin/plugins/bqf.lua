-- https://github.com/kevinhwang91/nvim-bqf
-- Prettifies the native quickfix window (fuzzy filter via the fzf binary
-- already on PATH, floating preview, syntax highlighting) without changing
-- the underlying quickfix mechanics - the dd/<leader>qC workflow in
-- core/quickfix.lua still works unchanged.
return {
	"kevinhwang91/nvim-bqf",
	ft = "qf",
	opts = {
		auto_enable = true,
		preview = {
			win_height = 12,
			win_vheight = 12,
			delay_syntax = 80,
			border = "rounded",
		},
	},
}
