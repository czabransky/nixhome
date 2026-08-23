vim.keymap.set("n", "]b", ":bnext<CR>", { desc = "Buffer Next" })
vim.keymap.set("n", "[b", ":bprevious<CR>", { desc = "Buffer Previous" })
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Buffer Next" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Buffer Previous" })
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Buffer Delete" })

local function close_buffers(keep_current)
	local current = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and not (keep_current and buf == current) then
			-- pcall: skip (leave open) any buffer nvim_buf_delete refuses to
			-- close, e.g. unsaved changes, rather than aborting the whole loop
			pcall(vim.api.nvim_buf_delete, buf, {})
		end
	end
end

vim.keymap.set("n", "<leader>ba", function()
	close_buffers(false)
end, { desc = "Buffer Close All" })

vim.keymap.set("n", "<leader>bo", function()
	close_buffers(true)
end, { desc = "Buffer Close Others" })
