local M = {}
local base_capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, blink = pcall(require, "blink.cmp")

if ok and type(blink.get_lsp_capabilities) == "function" then
	M.capabilities = blink.get_lsp_capabilities(base_capabilities)
else
	M.capabilities = base_capabilities
end

M.capabilities_with_snippets = vim.deepcopy(M.capabilities)
M.capabilities_with_snippets.textDocument = M.capabilities_with_snippets.textDocument or {}
M.capabilities_with_snippets.textDocument.completion = M.capabilities_with_snippets.textDocument.completion or {}
M.capabilities_with_snippets.textDocument.completion.completionItem =
	M.capabilities_with_snippets.textDocument.completion.completionItem or {}
M.capabilities_with_snippets.textDocument.completion.completionItem.snippetSupport = true

return M
