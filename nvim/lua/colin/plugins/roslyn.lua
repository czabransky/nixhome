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
			-- Default scope is "openFiles" - diagnostics only exist (and only
			-- show up in :Telescope diagnostics / <leader>xq / etc.) for
			-- buffers you've actually opened. "fullSolution" makes Roslyn
			-- push diagnostics for the whole solution in the background, so
			-- errors in files you haven't opened aren't hidden.
			settings = {
				["csharp|background_analysis"] = {
					dotnet_analyzer_diagnostics_scope = "fullSolution",
					dotnet_compiler_diagnostics_scope = "fullSolution",
				},
			},
		})

		require("roslyn").setup({})

		-- roslyn.nvim needs the actual language server binary, which isn't
		-- in Mason's official registry (licensing) - it comes from the
		-- Crashdummyy fork's "roslyn" package, kept installed declaratively
		-- via mason-tool-installer's ensure_installed list in plugins/lsp.lua
		-- (more reliable than a hand-rolled executable-check-and-install
		-- here - that approach silently broke once because is_installed()
		-- doesn't verify the bin symlink actually survived).
	end,
}
