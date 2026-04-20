local setup = require("colin.lsp.lsp-setup")
local attach = require("colin.lsp.lsp-attach")

vim.lsp.config("sqlls", {
	capabilities = setup.capabilities_with_snippets,
	on_attach = attach.on_attach,
})

vim.lsp.enable("sqlls")
