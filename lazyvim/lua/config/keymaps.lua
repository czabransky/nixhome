-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Press Enter to write the current buffer
vim.keymap.set("n", "<CR>", ":write<CR>", { silent = true, remap = true })

--  Cursorline should follow navigation
vim.keymap.set("n", "gg", "ggzz", { silent = true, remap = false })
vim.keymap.set("n", "G", "Gzz", { silent = true, remap = false })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { silent = true, remap = false })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { silent = true, remap = false })

--Copying/Pasting to/from the system register
vim.keymap.set("n", "Y", "y$", { silent = true, remap = false })
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { silent = true, remap = true })
vim.keymap.set({ "n", "v" }, "<leader>Y", '"+Y', { silent = true, remap = true })
vim.keymap.set("n", "gp", "`[v`]", { silent = true, remap = true })
vim.keymap.set("n", "<leader>p", '"_dP', { silent = true, remap = false })

-- Exiting Neovim should be easy
vim.keymap.set("n", "ZZ", ":wqa<CR>", { silent = true, remap = true })

-- Cancel highligts or close open popups with Escape
vim.keymap.set("n", "<esc>", function()
  for _, win in pairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == "win" then
      vim.api.nvim_win_close(win, false)
    end
  end
  vim.cmd(":noh")
end, { silent = true, desc = "Remove Search Highlighting, Dismiss Popups" })

-- VS Code Mappings
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
vim.keymap.set("n", "<leader>vc", open_in_vscode, { desc = "Open Current File in Visual Studio Code" })
-- As of 10/25/2024, you cannot combine /edit with /command, e.g., `devenv /edit % /command "GotoLn 50"`
vim.keymap.set("n", "<leader>vs", ":!devenv /edit %<CR>", { desc = "Open Current File in Visual Studio" })
