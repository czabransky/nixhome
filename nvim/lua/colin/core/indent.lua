-- o/O indent behavior for the current buffer's filetype:
--   smart_enabled = false (default) -> new lines copy the current line's
--     indent verbatim, since indentexpr="" falls back to plain autoindent.
--   smart_enabled = true -> Treesitter's indentexpr decides indent based on
--     syntax context (e.g. bump after an opening brace).
local M = {}

M.smart_enabled = false

function M.apply_current(buf)
	vim.bo[buf].indentexpr = M.smart_enabled and "v:lua.require'nvim-treesitter'.indentexpr()" or ""
end

function M.toggle()
	M.smart_enabled = not M.smart_enabled
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
			M.apply_current(buf)
		end
	end
	vim.notify("o/O indent: " .. (M.smart_enabled and "smart (treesitter)" or "same as current line"))
end

vim.keymap.set("n", "<leader>cI", M.toggle, { desc = "[C]ode Toggle Smart [I]ndent (o/O)" })

return M
