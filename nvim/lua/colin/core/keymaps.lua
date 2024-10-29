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
	vim.keymap.set({ "n", "x" }, "<leader>cr", function()
		vscode.with_insert(function()
			vscode.action("editor.action.refactor")
		end)
	end)
end

-- VS Code and Visual Studio Maps
-- For these keymaps to function, you need VS Code and/or Visual Studio executables to exist in the $PATH
local function open_in_vscode()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row, col = unpack(cursor)
	vim.cmd("!code --goto " .. vim.fn.expand("%") .. ":" .. row .. ":" .. col .. " --reuse-window")
end
vim.keymap.set("n", "<leader>gc", open_in_vscode, { desc = "Open Current File in Visual Studio Code" })
-- As of 10/25/2024, you cannot combine /edit with /command, e.g., `devenv /edit % /command "GotoLn 50"`
vim.keymap.set("n", "<leader>gs", ":!devenv /edit %<CR>", { desc = "Open Current File in Visual Studio" })
