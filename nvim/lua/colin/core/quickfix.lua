-- Custom quickfix column rendering (native vim.o.qftf, not bqf-specific) -
-- adapted from nvim-bqf's README "Customize quickfix window" demo. Renders
-- "filename │ lnum:col │ TYPE text" instead of the default raw dump; syntax
-- highlighting for it lives in nvim/syntax/qf.vim.
function _G.__colin_qftf(info)
	local items
	if info.quickfix == 1 then
		items = vim.fn.getqflist({ id = info.id, items = 0 }).items
	else
		items = vim.fn.getloclist(info.winid, { id = info.id, items = 0 }).items
	end

	-- Wider than bqf's own demo default (31) - this project's C# paths
	-- (src/Foo/Foo.Application/Auth/Commands/Whatever.cs) run deeper.
	local limit = 45
	local fname_fmt1, fname_fmt2 = "%-" .. limit .. "s", "…%." .. (limit - 1) .. "s"
	local valid_fmt = "%s │%5d:%-3d│%s %s"

	local ret = {}
	for i = info.start_idx, info.end_idx do
		local e = items[i]
		local str
		if e.valid == 1 then
			local fname = ""
			if e.bufnr > 0 then
				fname = vim.fn.bufname(e.bufnr)
				if fname == "" then
					fname = "[No Name]"
				else
					fname = fname:gsub("^" .. vim.env.HOME, "~")
				end
				if #fname <= limit then
					fname = fname_fmt1:format(fname)
				else
					fname = fname_fmt2:format(fname:sub(1 - limit))
				end
			end
			local lnum = e.lnum > 99999 and -1 or e.lnum
			local col = e.col > 999 and -1 or e.col
			local qtype = e.type == "" and "" or " " .. e.type:sub(1, 1):upper()
			str = valid_fmt:format(fname, lnum, col, qtype, e.text)
		else
			str = e.text
		end
		table.insert(ret, str)
	end
	return ret
end
vim.o.qftf = "{info -> v:lua.__colin_qftf(info)}"

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
