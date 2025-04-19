-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.cmd.colorscheme("catppuccin-frappe")

-- Options to make markdown more readable
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪ "
vim.opt.colorcolumn = "80"

vim.opt.spell = true
vim.opt.textwidth = 80 -- this affects `gq` formatting, not visual wrap
