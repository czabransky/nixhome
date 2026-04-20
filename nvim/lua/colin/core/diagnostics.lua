local function send_diagnostics_to_quickfix()
	-- Get diagnostics from the LSP for the current buffer
	local bufnr = vim.api.nvim_get_current_buf()
	local diagnostics = vim.diagnostic.get(bufnr)
	local qflist = {}

	-- Populate a table with diagnostics
	for _, diagnostic in ipairs(diagnostics) do
		table.insert(qflist, {
			bufnr = bufnr,
			lnum = diagnostic.lnum + 1,
			col = diagnostic.col + 1,
			text = diagnostic.message,
		})
	end

	-- Update and open the qflist
	vim.fn.setqflist(qflist)
	vim.cmd("copen")
end

vim.keymap.set("n", "<leader>dl", send_diagnostics_to_quickfix, { desc = "Quickfix [D]iagnostics [L]ist" })

local function jump_diag(count, severity)
	vim.diagnostic.jump({ count = count, severity = severity })
	vim.cmd.normal({ "zz", bang = true })
end

vim.keymap.set("n", "<leader>e", function()
	jump_diag(1)
end, { desc = "Go to Next Diagnostic" })

vim.keymap.set("n", "]d", function()
	jump_diag(1)
end, { desc = "Go to Next Diagnostic" })

vim.keymap.set("n", "[d", function()
	jump_diag(-1)
end, { desc = "Go to Previous Diagnostic" })

vim.keymap.set("n", "]e", function()
	jump_diag(1, vim.diagnostic.severity.ERROR)
end, { desc = "Go to Next Error" })

vim.keymap.set("n", "[e", function()
	jump_diag(-1, vim.diagnostic.severity.ERROR)
end, { desc = "Go to Previous Error" })

vim.keymap.set("n", "]w", function()
	jump_diag(1, vim.diagnostic.severity.WARN)
end, { desc = "Go to Next Warning" })

vim.keymap.set("n", "[w", function()
	jump_diag(-1, vim.diagnostic.severity.WARN)
end, { desc = "Go to Previous Warning" })

vim.keymap.set("n", "<leader>cn", ":cnext<CR>zz", { desc = "Navigate to [N]ext Quickfix Item" })
vim.keymap.set("n", "<leader>cp", ":cprevious<CR>zz", { desc = "Navigate to [P]revious Quickfix Item" })
vim.keymap.set("n", "<leader>co", ":copen<CR>", { desc = "[O]pen the Quickfix List" })
vim.keymap.set("n", "<leader>cc", ":cclose<CR>", { desc = "[C]lose the Quickfix List" })
