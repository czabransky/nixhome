vim.keymap.set("n", "<leader>cl", function()
	vim.opt_local.list = not vim.opt_local.list:get()
end, { desc = "[C]ode Toggle White[l]space" })

vim.keymap.set("n", "<leader>cw", function()
	vim.wo.wrap = not vim.wo.wrap
end, { desc = "[C]ode Toggle [W]rap" })

vim.keymap.set("n", "<esc>", function()
	for _, win in pairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(win).relative == "win" then
			vim.api.nvim_win_close(win, false)
		end
	end
	vim.cmd(":noh")
end, { silent = true, desc = "Remove Search Highlighting, Dismiss Popups" })

-- VS Code
if vim.g.vscode then
	local vscode = require("vscode")
	vim.keymap.set({ "n", "x" }, "<leader>ca", function()
		vscode.with_insert(function()
			vscode.action("editor.action.refactor")
		end)
	end)
end
