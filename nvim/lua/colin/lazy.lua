-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
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
		notify = false,
	},
	change_detection = {
		enabled = false,
		notify = false,
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

	require("colin.plugins.bqf"),
	require("colin.plugins.bufferline"),
	require("colin.plugins.cmp").blinkcmp(),
	require("colin.plugins.conform"),
	require("colin.plugins.dap").core(),
	require("colin.plugins.dap").js_debug(),
	require("colin.plugins.dap").js_adapter(),
	require("colin.plugins.flash"),
	require("colin.plugins.fzf-native"),
	require("colin.plugins.gitsigns"),
	require("colin.plugins.grapple"),
	require("colin.plugins.kulala"),
	require("colin.plugins.lazygit"),
	require("colin.plugins.lsp"),
	require("colin.plugins.lualine"),
	require("colin.plugins.mini"),
	require("colin.plugins.neogen"),
	require("colin.plugins.noice"),
	require("colin.plugins.overseer"),
	require("colin.plugins.persistence"),
	require("colin.plugins.render-markdown"),
	require("colin.plugins.roslyn"),
	require("colin.plugins.sleuth"),
	require("colin.plugins.theme").catppuccin(),
	require("colin.plugins.theme").everforest(),
	require("colin.plugins.theme").gruvbox(),
	require("colin.plugins.theme").kanagawa(),
	require("colin.plugins.theme").onedark(),
	require("colin.plugins.theme").tokyonight(),
	require("colin.plugins.todo-comments"),
	require("colin.plugins.tree").nvimtree(),
	require("colin.plugins.telescope"),
	require("colin.plugins.treesitter"),
	require("colin.plugins.whichkey"),
})
