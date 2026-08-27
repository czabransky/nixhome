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

-- Two-argument form deliberately: `setup({ <options-as-keys>, <plugin specs
-- as array entries> })` looks like it should work as a single merged table,
-- but lazy.nvim's spec parser only reads the array part of that table (see
-- Spec:normalize in lazy/core/plugin.lua - it branches on #spec/is_list,
-- which only sees numeric indices) - the dictionary keys (checker, rocks,
-- ui, ...) were silently no-ops, confirmed live via
-- require("lazy.core.config").options reading the *defaults* for all of
-- them despite being set below. Passing options as an explicit second
-- argument is the only form that's actually respected.
require("lazy").setup({
	require("colin.plugins.bqf"),
	require("colin.plugins.bufferline"),
	require("colin.plugins.cmp").blinkcmp(),
	require("colin.plugins.conform"),
	require("colin.plugins.dap").core(),
	require("colin.plugins.dap").js_debug(),
	require("colin.plugins.dap").js_adapter(),
	require("colin.plugins.excalidraw"),
	require("colin.plugins.flash"),
	require("colin.plugins.fzf-native"),
	require("colin.plugins.gitsigns"),
	require("colin.plugins.grapple"),
	require("colin.plugins.lazygit"),
	require("colin.plugins.lsp"),
	require("colin.plugins.lualine"),
	require("colin.plugins.marks"),
	require("colin.plugins.mini"),
	require("colin.plugins.neogen"),
	require("colin.plugins.noice"),
	require("colin.plugins.overseer"),
	require("colin.plugins.persistence"),
	require("colin.plugins.render-markdown"),
	require("colin.plugins.rest"),
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
	require("colin.plugins.window-picker"),
}, {
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		enabled = false,
		notify = false,
	},
	-- lazy.nvim's own luarocks integration (hererocks) is broken for
	-- rest.nvim's tree-sitter-http rock - see plugins/rest.lua for the
	-- workaround. No installed plugin here has a rockspec with real
	-- (non-"lua") deps otherwise, so disabling it globally is safe.
	rocks = {
		enabled = false,
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
})
