-- https://github.com/mistweaverco/kulala.nvim
-- HTTP client for .http/.rest files (JetBrains .http spec). No special glue
-- needed to use it alongside nvim-dap: launch/attach the debugger (dap.lua)
-- as normal, set breakpoints, then send a request from here - it's the same
-- running process, so the breakpoint just gets hit.
return {
	"mistweaverco/kulala.nvim",
	ft = { "http", "rest" },
	config = function()
		require("kulala").setup({
			global_keymaps = false,
			lsp = {
				-- Kulala ships its own built-in LSP for .http/.rest buffers
				-- (documentSymbol/hover/completion/codeAction) but starts it
				-- outside nvim-lspconfig, so it never picks up
				-- lsp-attach.lua's on_attach on its own - without this,
				-- <leader>ss (Search Symbols) and the rest of the shared LSP
				-- keymaps just don't exist here.
				on_attach = require("colin.lsp.lsp-attach").on_attach,
			},
		})

		local kulala = require("kulala")
		vim.keymap.set("n", "<leader>Rs", kulala.run, { desc = "[R]equest [S]end" })
		vim.keymap.set("n", "<leader>Ra", kulala.run_all, { desc = "[R]equest Send [A]ll" })
		vim.keymap.set("n", "<leader>Rr", kulala.replay, { desc = "[R]equest [R]eplay Last" })
		vim.keymap.set("n", "<leader>Rb", kulala.scratchpad, { desc = "[R]equest Scratchpad ([B])" })
		vim.keymap.set("n", "<leader>Re", kulala.set_selected_env, { desc = "[R]equest Select [E]nvironment" })
		vim.keymap.set("n", "<leader>Ro", kulala.open, { desc = "[R]equest [O]pen Window" })
	end,
}
