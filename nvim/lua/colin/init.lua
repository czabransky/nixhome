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

-- Rainbow Trails but BUSINESS style
vim.cmd.highlight("RainbowRed guibg=#808080 ctermbg=244")
vim.cmd.highlight("RainbowOrange guibg=#6c6c6c ctermbg=242")
vim.cmd.highlight("RainbowYellow guibg=#585858 ctermbg=240")
vim.cmd.highlight("RainbowGreen guibg=#444444 ctermbg=238")
vim.cmd.highlight("RainbowBlue guibg=#303030 ctermbg=236")
vim.cmd.highlight("RainbowIndigo guibg=#1c1c1c ctermbg=234")
vim.cmd.highlight("RainbowViolet guibg=#080808 ctermbg=232")
