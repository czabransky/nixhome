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
			-- Quickfix/location-list windows are unnamed ("[No Name]") and
			-- share buftype="quickfix" - hide them from the tab bar.
			custom_filter = function(buf_number)
				return vim.bo[buf_number].buftype ~= "quickfix"
			end,
		},
	},
}
