local setup = require("colin.lsp.lsp-setup")

-- No on_attach override here: eslint's default lspconfig on_attach registers
-- the :LspEslintFixAll command, and the shared gd/K/etc. keymaps are already
-- registered by whichever other LSP client (ts_ls) attaches to the buffer.
vim.lsp.config("eslint", {
	capabilities = setup.capabilities_with_snippets,
})

vim.lsp.enable("eslint")
