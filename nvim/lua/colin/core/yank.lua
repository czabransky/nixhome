local function copy(value, desc)
	vim.fn.setreg("+", value)
	vim.notify(("Copied %s: %s"):format(desc, value))
end

vim.keymap.set("n", "<leader>yy", function()
	copy(vim.fn.expand("%:p"), "absolute path")
end, { desc = "Yank Absolute Path" })

vim.keymap.set("n", "<leader>yr", function()
	-- expand("%") just returns however the buffer was opened (often already
	-- absolute, e.g. via telescope/nvim-tree/LSP jumps) - recompute relative
	-- to cwd from the absolute path instead of trusting that.
	copy(vim.fn.fnamemodify(vim.fn.expand("%:p"), ":."), "relative path")
end, { desc = "Yank Relative Path" })

vim.keymap.set("n", "<leader>yn", function()
	copy(vim.fn.expand("%:t"), "file name")
end, { desc = "Yank File Name" })
