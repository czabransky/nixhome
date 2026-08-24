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
		-- Crashdummyy fork already added in plugins/lsp.lua. Without this,
		-- the client fails to spawn silently and on_attach never fires.
		-- Gate on a cheap executable check so this costs nothing once
		-- installed - it only does anything on a fresh machine.
		local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "roslyn-language-server")
		if vim.fn.executable(mason_bin) == 0 then
			require("mason-registry").refresh(function()
				local ok, pkg = pcall(require("mason-registry").get_package, "roslyn")
				if ok and not pkg:is_installed() then
					pkg:install()
				end
			end)
		end
	end,
}
