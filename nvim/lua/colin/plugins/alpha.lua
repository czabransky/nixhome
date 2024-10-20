return {
	'goolord/alpha-nvim',
	dependencies = {
		{ 'nvim-tree/nvim-web-devicons' },
		{ 'nvim-lua/plenary.nvim' },
	},
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Set header
		dashboard.section.header.val = {
			"                                                     ",
			"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
			"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
			"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
			"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
			"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
			"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
			"                                                     ",
		}
		-- dashboard.section.header.opts.hl = "tag"

		-- Set menu
		dashboard.section.buttons.val = {
			dashboard.button("e", "  > new file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("f", "󰍉  > find file", ":Telescope find_files<CR>"),
			dashboard.button("r", "  > recent", ":Telescope oldfiles<CR>"),
			dashboard.button("s", "  > settings", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k | pwd<CR>"),
			dashboard.button("q", "󰈆  > quit", ":qa<CR>"),
		}

		-- Send config to alpha
		alpha.setup(dashboard.opts)

		-- Disable folding on alpha buffer
		vim.cmd([[ autocmd FileType alpha setlocal nofoldenable ]])
	end
}
