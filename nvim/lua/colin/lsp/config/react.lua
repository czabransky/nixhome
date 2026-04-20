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
		hostInfo = "neovim",
	},
	settings = {
		typescript = {
			suggest = {
				completeFunctionCalls = true,
			},
			inlayHints = {
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayVariableTypeHints = false,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayEnumMemberValueHints = true,
			},
		},
		javascript = {
			suggest = {
				completeFunctionCalls = true,
			},
			inlayHints = {
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayVariableTypeHints = false,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayEnumMemberValueHints = true,
			},
		},
	},
	on_attach = attach.on_attach,
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	single_file_support = false,
})

vim.lsp.enable("ts_ls")
