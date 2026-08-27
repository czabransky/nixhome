-- https://github.com/j-hui/fidget.nvim
-- Not used here for its more common job (LSP progress) - it's a plain
-- dependency of two unrelated plugins that call fidget.progress.handle
-- directly for their own non-LSP progress indicators: rest.nvim's curl
-- client (client/curl/cli.lua, one handle per HTTP request) and
-- plugins/dap.lua's dotnet build step. Declared as its own top-level plugin
-- (not nested under either dependent's `dependencies`) so this setup() call
-- is the one that wins regardless of which one happens to load - and
-- require()s it - first.
return {
	"j-hui/fidget.nvim",
	lazy = false,
	config = function()
		require("fidget").setup({
			notification = {
				-- rest.nvim's per-request handles pop a toast for every
				-- single request in a run_all() chain, duplicating what
				-- plugins/rest.lua's own Report tab already shows - just
				-- noise there. dap.lua's dotnet-build indicator should stay
				-- visible though.
				--
				-- Can't tell them apart by level: progress.lua's
				-- format_progress() hardcodes vim.log.levels.INFO for
				-- EVERY fidget.progress caller, rest.nvim included, so a
				-- numeric level filter is all-or-nothing across every
				-- consumer of this plugin. Group name is the only signal
				-- that differs - notification_group() (progress.lua)
				-- returns msg.lsp_client.name, which rest.nvim never sets
				-- (defaults to handle.create()'s own fallback, "fidget"),
				-- while dap.lua explicitly sets lsp_client = { name = "dap" }
				-- specifically so it keeps a distinct group here.
				redirect = function(_, _, opts)
					return opts and opts.group == "fidget"
				end,
			},
		})
	end,
}
