vim.keymap.set("n", "<esc>", function()
	for _, win in pairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_config(win).relative == "win" then
			vim.api.nvim_win_close(win, false)
		end
	end
	vim.cmd(":noh")
end, { silent = true, desc = "Remove Search Highlighting, Dismiss Popups" })

-- [[ Diagnostics ]]
vim.keymap.set("n", "<leader>e", function()
	vim.diagnostic.goto_next({})
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Go to Next Diagnostic" })

vim.keymap.set("n", "]d", function()
	vim.diagnostic.goto_next({})
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Go to Next Diagnostic" })

vim.keymap.set("n", "[d", function()
	vim.diagnostic.goto_prev({})
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Go to Previous Diagnostic" })

vim.keymap.set("n", "]e", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Go to Next Error" })

vim.keymap.set("n", "[e", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Go to Previous Error" })

vim.keymap.set("n", "]w", function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Go to Next Warning" })

vim.keymap.set("n", "[w", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
	vim.api.nvim_feedkeys("zz", "n", false)
end, { desc = "Go to Previous Warning" })

vim.keymap.set("n", "<leader>ld", vim.diagnostic.setqflist, { desc = "Quickfix [L]ist [D]iagnostics" })
vim.keymap.set("n", "<leader>cn", ":cnext<CR>zz", { desc = "Navigate to [N]ext Quickfix Item" })
vim.keymap.set("n", "<leader>cp", ":cprevious<CR>zz", { desc = "Navigate to [P]revious Quickfix Item" })
vim.keymap.set("n", "<leader>co", ":copen<CR>", { desc = "[O]pen the Quickfix List" })
vim.keymap.set("n", "<leader>cc", ":cclose<CR>", { desc = "[C]lose the Quickfix List" })

-- VS Code
if vim.g.vscode then
	local vscode = require("vscode")
	vim.keymap.set({ "n", "x" }, "<leader>cr", function()
		vscode.with_insert(function()
			vscode.action("editor.action.refactor")
		end)
	end)
end

-- VS Code and Visual Studio Maps
-- For these keymaps to function, you need VS Code and/or Visual Studio executables to exist in the $PATH
vim.keymap.set("n", "<leader>gc", ":!code %<CR>", { desc = "Open Current File in Visual Studio Code" })
vim.keymap.set("n", "<leader>gs", ":!devenv /edit %<CR>", { desc = "Open Current File in Visual Studio" })
