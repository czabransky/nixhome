-- Telescope's <C-q> (smart_add_to_qflist) appends to the existing quickfix
-- list rather than replacing it, so starting a fresh set needs an explicit
-- clear first.
vim.keymap.set("n", "<leader>qC", function()
	vim.fn.setqflist({})
	vim.notify("Quickfix list cleared")
end, { desc = "Quickfix Clear" })

-- Remove the entry under the cursor from the quickfix list (e.g. as you work
-- through references and mark each one done), keeping the list open and
-- the cursor on a sensible remaining entry.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function(args)
		vim.keymap.set("n", "dd", function()
			local qflist = vim.fn.getqflist()
			local idx = vim.fn.line(".")
			table.remove(qflist, idx)
			vim.fn.setqflist(qflist)
			if #qflist > 0 then
				vim.api.nvim_win_set_cursor(0, { math.min(idx, #qflist), 0 })
			end
		end, { buffer = args.buf, desc = "Quickfix Remove Item" })
	end,
})
