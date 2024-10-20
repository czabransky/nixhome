require('mason-lspconfig').setup {
	ensure_installed = vim.tbl_keys({
		omnisharp = {},
		html = {},
		cssls = {},
		emmet_ls = {},
		ts_ls = {},
	}),
}
require('colin.lsp.config.html')
require('colin.lsp.config.react')
require('colin.lsp.config.csharp')
