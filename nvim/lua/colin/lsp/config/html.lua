local setup = require("colin.lsp.lsp-setup")
local attach = require("colin.lsp.lsp-attach")
local emmet_bin = vim.fn.exepath("emmet-language-server")
if emmet_bin == "" then
	emmet_bin = vim.fn.exepath("emmet_ls")
end
if emmet_bin == "" then
	emmet_bin = "emmet-language-server"
end
local webfiles = {
	"html",
	"css",
	"scss",
	"less",
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
}

vim.lsp.config("cssls", {
	capabilities = setup.capabilities_with_snippets,
	filetypes = webfiles,
	on_attach = attach.on_attach,
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
})

vim.lsp.config("html", {
	capabilities = setup.capabilities,
	filetypes = webfiles,
	on_attach = attach.on_attach,
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
})

vim.lsp.config("emmet_language_server", {
	cmd = { emmet_bin, "--stdio" },
	capabilities = setup.capabilities_with_snippets,
	on_attach = attach.on_attach,
	filetypes = webfiles,
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	init_options = {
		html = {
			options = {
				["bem.enabled"] = true,
			},
		},
	},
})

vim.lsp.enable("cssls")
vim.lsp.enable("html")
vim.lsp.enable("emmet_language_server")
