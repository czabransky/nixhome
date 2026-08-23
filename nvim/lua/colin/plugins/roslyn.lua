return {
	"seblyng/roslyn.nvim",
	config = function()
		local setup = require("colin.lsp.lsp-setup")
		local attach = require("colin.lsp.lsp-attach")

		-- roslyn.nvim's own setup() only takes target-resolution/filewatching
		-- options (RoslynNvimConfig) - on_attach/capabilities go through the
		-- native vim.lsp.config() API instead, same as the other lsp/config/*
		-- servers, and merge into roslyn.nvim's bundled lsp/roslyn.lua config.
		vim.lsp.config("roslyn", {
			capabilities = setup.capabilities_with_snippets,
			on_attach = attach.on_attach,
		})

		require("roslyn").setup({})
	end,
}
