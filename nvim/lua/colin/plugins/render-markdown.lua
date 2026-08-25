return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	ft = { "markdown", "kulala_ui" },
	opts = {
		-- kulala's response/headers/report panes use filetype "kulala_ui"
		-- (with a markdown treesitter parser attached) so they render here too.
		file_types = { "markdown", "kulala_ui" },
	},
}
