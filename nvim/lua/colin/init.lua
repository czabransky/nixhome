require("colin.core.options").setup({
	inherit_vimrc = true,
	leader = " ",
})
require("colin.core.keymaps")
require("colin.core.autocmd")
require("colin.core.diagnostics")
require("colin.lazy")
require("colin.lsp")

vim.cmd.colorscheme("catppuccin-frappe")
