local lspconfig = require("lspconfig")
local setup = require("colin.lsp.lsp-setup")
local attach = require("colin.lsp.lsp-attach")

lspconfig.lua_ls.setup({
	capabilities = setup.capabilities_with_snippets,
	on_attach = attach.on_attach,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})
