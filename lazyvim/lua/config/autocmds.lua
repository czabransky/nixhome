-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

vim.api.nvim_create_autocmd("FileType", {
  desc = "Disable newline comments when inserting lines with o/O",
  group = defaults,
  pattern = { "*" },
  callback = function()
    vim.opt_local.formatoptions:remove("o")
  end,
})
