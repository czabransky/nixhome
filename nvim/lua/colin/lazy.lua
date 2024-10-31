-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath) -- noqa

require("lazy").setup({
	checker = {
		enabled = true,
		notify = true,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
	ui = {
		border = "single",
	},

	require("colin.plugins.alpha"),
	-- require('colin.plugins.cmp').blinkcmp(),
	require("colin.plugins.cmp").nvimcmp(),
	require("colin.plugins.conform"),
	require("colin.plugins.gitsigns"),
	require("colin.plugins.glow"),
	require("colin.plugins.grapple"),
	require("colin.plugins.lsp"),
	require("colin.plugins.lualine"),
	require("colin.plugins.mini"),
	require("colin.plugins.neogen"),
	require("colin.plugins.noice"),
	require("colin.plugins.rainbowtrails"),
	require("colin.plugins.theme").tokyonight(),
	require("colin.plugins.theme").catppuccin(),
	require("colin.plugins.tree").nvimtree(),
	require("colin.plugins.telescope"),
	require("colin.plugins.treesitter"),
	require("colin.plugins.vim-commentary"),
	require("colin.plugins.vim-surround"),
	require("colin.plugins.vim-tmux-navigator"),
	require("colin.plugins.whichkey"),
})
