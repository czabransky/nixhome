-- nvim-lspconfig lsp names can be found here:
-- https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/config

require("mason-lspconfig").setup({
	ensure_installed = vim.tbl_keys({
		lua_ls = {},
		omnisharp = {},
		html = {},
		cssls = {},
		emmet_ls = {},
		ts_ls = {},
		sqlls = {},
	}),
})
require("colin.lsp.config.lua")
require("colin.lsp.config.html")
require("colin.lsp.config.react")
require("colin.lsp.config.csharp")
require("colin.lsp.config.sql")
