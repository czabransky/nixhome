-- Telescope's <C-q> (smart_add_to_qflist) appends to the existing quickfix
-- list rather than replacing it, so starting a fresh set needs an explicit
-- clear first.
vim.keymap.set("n", "<leader>qC", function()
	vim.fn.setqflist({})
	vim.notify("Quickfix list cleared")
end, { desc = "Quickfix Clear" })

-- z-prefixed to match nvim-bqf's own qf-buffer conventions (zn/zN/zf).
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function(args)
		local opts = { buffer = args.buf }

		-- Remove the entry under the cursor (e.g. as you work through
		-- references and mark each one done), keeping the list open and the
		-- cursor on a sensible remaining entry.
		vim.keymap.set(
			"n",
			"zd",
			function()
				local qflist = vim.fn.getqflist()
				local idx = vim.fn.line(".")
				table.remove(qflist, idx)
				vim.fn.setqflist(qflist)
				if #qflist > 0 then
					vim.api.nvim_win_set_cursor(0, { math.min(idx, #qflist), 0 })
				end
			end,
			vim.tbl_extend("force", opts, { desc = "Quickfix Remove Item" })
		)

		-- Same as <leader>qC, available without leaving the qf window.
		vim.keymap.set(
			"n",
			"zc",
			function()
				vim.fn.setqflist({})
			end,
			vim.tbl_extend("force", opts, { desc = "Quickfix Clear" })
		)
	end,
})
