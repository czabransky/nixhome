-- nvim-lspconfig lsp names can be found here:
-- https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/config

require("mason-lspconfig").setup({
	ensure_installed = vim.tbl_keys({
		lua_ls = {},
		html = {},
		cssls = {},
		emmet_language_server = {},
		ts_ls = {},
		sqlls = {},
		biome = {},
		eslint = {},
	}),
	automatic_enable = false,
})
require("colin.lsp.config.lua")
require("colin.lsp.config.html")
require("colin.lsp.config.react")
require("colin.lsp.config.sql")
require("colin.lsp.config.biome")
require("colin.lsp.config.eslint")
