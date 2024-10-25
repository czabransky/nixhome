local function send_diagnostics_to_quickfix()
	-- Get diagnostics from the LSP for the current buffer
	local bufnr = vim.api.nvim_get_current_buf()
	local diagnostics = vim.diagnostic.get(bufnr)
	local qflist = {}

	-- Populate a table with diagnostics
	for _, diagnostic in ipairs(diagnostics) do
		table.insert(qflist, {
			bufnr = bufnr,
			lnum = diagnostic.lnum,
			col = diagnostic.col,
			text = diagnostic.message,
		})
	end

	-- Update and open the qflist
	vim.fn.setqflist(qflist)
	vim.cmd("copen")
end

vim.keymap.set("n", "<leader>dl", send_diagnostics_to_quickfix, { desc = "Quickfix [D]iagnostics [L]ist" })

vim.keymap.set("n", "<leader>e", function()
	vim.diagnostic.goto_next({})
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Go to Next Diagnostic" })

vim.keymap.set("n", "]d", function()
	vim.diagnostic.goto_next({})
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Go to Next Diagnostic" })

vim.keymap.set("n", "[d", function()
	vim.diagnostic.goto_prev({})
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Go to Previous Diagnostic" })

vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Go to Next Error" })

vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Go to Previous Error" })

vim.keymap.set("n", "]w", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Go to Next Warning" })

vim.keymap.set("n", "[w", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Go to Previous Warning" })

vim.keymap.set("n", "<leader>cn", ":cnext<CR>zz", { desc = "Navigate to [N]ext Quickfix Item" })
vim.keymap.set("n", "<leader>cp", ":cprevious<CR>zz", { desc = "Navigate to [P]revious Quickfix Item" })
vim.keymap.set("n", "<leader>co", ":copen<CR>", { desc = "[O]pen the Quickfix List" })
vim.keymap.set("n", "<leader>cc", ":cclose<CR>", { desc = "[C]lose the Quickfix List" })
