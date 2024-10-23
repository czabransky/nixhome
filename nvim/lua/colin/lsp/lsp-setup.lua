local M = {}
M.capabilities = require('cmp_nvim_lsp').default_capabilities(
	vim.lsp.protocol.make_client_capabilities()
)
M.capabilities_with_snippets = require('cmp_nvim_lsp').default_capabilities(
	vim.lsp.protocol.make_client_capabilities()
)
M.capabilities_with_snippets.textDocument.completion.completionItem.snippetSupport = true
return M
