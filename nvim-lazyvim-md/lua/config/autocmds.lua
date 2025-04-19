vim.api.nvim_create_autocmd("FileType", {
  desc = "Disable newline comments when inserting lines with o/O",
  group = defaults,
  pattern = { "*" },
  callback = function()
    vim.opt_local.formatoptions:remove("o")
  end,
})
