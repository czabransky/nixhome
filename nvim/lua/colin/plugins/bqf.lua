-- https://github.com/kevinhwang91/nvim-bqf
-- Prettifies the native quickfix window (floating preview, syntax
-- highlighting) without changing the underlying quickfix mechanics - the
-- zd/zc/<leader>qC workflow in core/quickfix.lua still works unchanged.
return {
	"kevinhwang91/nvim-bqf",
	ft = "qf",
	dependencies = {
		-- zf (fzf mode) needs the real fzf *Vim plugin* for its fzf#run
		-- function - the fzf binary alone (already on PATH via nix) isn't
		-- enough, bqf calls into fzf#run directly. No build step: that only
		-- vendors fzf's own binary inside the plugin dir for people without
		-- fzf installed (and fails anyway under lazy.nvim, since fzf#install
		-- isn't sourced yet at build time) - fzf#run loads fine on its own
		-- just from being on the runtimepath, and we already have fzf via nix.
		"junegunn/fzf",
	},
	opts = {
		auto_enable = true,
		preview = {
			win_height = 12,
			win_vheight = 12,
			delay_syntax = 80,
			border = "rounded",
		},
		filter = {
			fzf = {
				-- Matches the "│" field separator core/quickfix.lua's qftf
				-- formats entries with.
				extra_opts = { "--bind", "ctrl-o:toggle-all", "--delimiter", "│" },
			},
		},
	},
}
