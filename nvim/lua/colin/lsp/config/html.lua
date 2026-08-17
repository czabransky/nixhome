local setup = require("colin.lsp.lsp-setup")
local attach = require("colin.lsp.lsp-attach")
local emmet_bin = vim.fn.exepath("emmet-language-server")
if emmet_bin == "" then
	emmet_bin = vim.fn.exepath("emmet_ls")
end
if emmet_bin == "" then
	emmet_bin = "emmet-language-server"
end
-- Only emmet's abbreviation expansion is useful on JS/TS files (JSX-embedded
-- markup); the actual CSS/HTML servers have no business attaching there —
-- doing so put cssls/html into the textDocument/documentSymbol fan-out
-- alongside ts_ls and broke telescope's lsp_document_symbols aggregation.
local css_files = { "css", "scss", "less" }
local html_files = { "html" }
local emmet_files = {
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
	filetypes = css_files,
	on_attach = attach.on_attach,
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
})

vim.lsp.config("html", {
	capabilities = setup.capabilities,
	filetypes = html_files,
	on_attach = attach.on_attach,
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
})

vim.lsp.config("emmet_language_server", {
	cmd = { emmet_bin, "--stdio" },
	capabilities = setup.capabilities_with_snippets,
	on_attach = attach.on_attach,
	filetypes = emmet_files,
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
