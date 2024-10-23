local lspconfig = require('lspconfig')
local configs = require('lspconfig/configs')
local setup = require('colin.lsp.lsp-setup')
local attach = require('colin.lsp.lsp-attach')

lspconfig.omnisharp.setup({
	capabilities = setup.capabilities_with_snippets,
	filetypes = {
		'cs',
		'csharp',
	},
	on_attach = attach.on_attach,
})
