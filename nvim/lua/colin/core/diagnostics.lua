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

vim.keymap.set("n", "<leader>xq", send_diagnostics_to_quickfix, { desc = "Diagnostics to Quickfix" })

local function jump_diag(count, severity)
	vim.diagnostic.jump({ count = count, severity = severity })
	vim.cmd.normal({ "zz", bang = true })
end

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

vim.keymap.set("n", "]q", ":cnext<CR>zz", { desc = "Quickfix Next" })
vim.keymap.set("n", "[q", ":cprevious<CR>zz", { desc = "Quickfix Previous" })
vim.keymap.set("n", "<leader>qo", ":copen<CR>", { desc = "Quickfix Open" })
vim.keymap.set("n", "<leader>qc", ":cclose<CR>", { desc = "Quickfix Close" })
