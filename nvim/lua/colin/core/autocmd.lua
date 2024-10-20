-- [[ Highlight on Yank ]]
-- see `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank({
			timeout = 250
		})
	end,
	group = highlight_group,
	pattern = "*",
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "Disable newline comments when inserting lines with o/O",
	group = defaults,
	pattern = { "*" },
	callback = function() vim.opt_local.formatoptions:remove("o") end,
})
