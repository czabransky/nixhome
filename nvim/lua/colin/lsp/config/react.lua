local lspconfig = require('lspconfig')
local configs = require('lspconfig/configs')
local setup = require('colin.lsp.lsp-setup')
local attach = require('colin.lsp.lsp-attach')

lspconfig.ts_ls.setup({
	capabilities = setup.capabilities_with_snippets,
	filetypes = {
		'js',
		'ts',
		'tsx',
		'javascript',
		'javascriptreact',
		'javascript.jsx',
		'typescript',
		'typescriptreact',
		'typescript.tsx',
	},
	init_options = {
		enable = true,
		lint = true,
		preferences = {
			disableSuggestions = true,
		},
	},
	on_attach = attach.on_attach,
	-- commands = {
	--
	-- },
	root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
})
