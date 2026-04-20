local setup = require("colin.lsp.lsp-setup")
local attach = require("colin.lsp.lsp-attach")

vim.lsp.config("ts_ls", {
	capabilities = setup.capabilities_with_snippets,
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	init_options = {
		enable = true,
		lint = true,
		preferences = {
			disableSuggestions = true,
		},
	},
	on_attach = attach.on_attach,
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	single_file_support = false,
})

vim.lsp.enable("ts_ls")
