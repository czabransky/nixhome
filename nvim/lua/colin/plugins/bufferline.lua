return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	opts = {
		options = {
			diagnostics = "nvim_lsp",
			offsets = {
				{ filetype = "NvimTree", text = "Explorer", separator = true },
			},
		},
	},
}
