local setup = require("colin.lsp.lsp-setup")
local attach = require("colin.lsp.lsp-attach")

vim.lsp.config("lua_ls", {
	capabilities = setup.capabilities_with_snippets,
	on_attach = attach.on_attach,
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
		},
	},
})

vim.lsp.enable("lua_ls")
