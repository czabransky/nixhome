local lspconfig = require('lspconfig')
local configs = require('lspconfig/configs')
local setup = require('colin.lsp.lsp-setup')
local attach = require('colin.lsp.lsp-attach')
local webfiles = {
	'html',
	'css',
	'scss',
	'less',
	'jsx',
	'js',
	'ts',
	'tsx',
	'javascript',
	'javascriptreact',
	'javascript.jsx',
	'typescript',
	'typescriptreact',
	'typescript.tsx',
}

lspconfig.cssls.setup({
	capabilities = setup.capabilities_with_snippets,
	filetypes = webfiles,
	on_attach = attach.on_attach,
})

lspconfig.html.setup({
	capabilities = setup.capabilities,
	on_attach = attach.on_attach,
})

if not lspconfig.emmet_ls then
	configs.emmet_ls = {
		default_config = {
			cmd = { 'emmet_ls', '--stdio' },
			filetypes = webfiles,
			root_dir = function(fname)
				return vim.loop.cwd()
			end,
			settings = {},
		},
	}
end

lspconfig.emmet_ls.setup({
	capabilities = setup.capabilities_with_snippets,
	filetypes = webfiles,
	init_options = {
		html = {
			options = {
				['bem.enabled'] = true,
			},
		},
	},
})
