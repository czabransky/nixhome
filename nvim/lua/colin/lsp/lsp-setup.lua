local M = {}
local base_capabilities = vim.lsp.protocol.make_client_capabilities()

-- Force every server onto the same offset_encoding. Neovim offers utf-8/utf-16/utf-32
-- and each server picks its own preferred one; when two clients on the same buffer
-- (e.g. ts_ls + biome) pick differently, requests that aggregate across clients
-- (like Telescope's document_symbols) warn and guess. utf-16 is the original
-- LSP-mandated default that every server supports, so restricting to it avoids
-- any divergence.
base_capabilities.general = base_capabilities.general or {}
base_capabilities.general.positionEncodings = { "utf-16" }

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
