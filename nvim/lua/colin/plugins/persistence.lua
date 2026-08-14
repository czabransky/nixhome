return {
	"folke/persistence.nvim",
	event = "BufReadPre",
	opts = {},
	keys = {
		{
			"<leader>wo",
			function()
				require("persistence").load()
			end,
			desc = "Restore Session",
		},
		{
			"<leader>wp",
			function()
				require("persistence").select()
			end,
			desc = "Select Session",
		},
		{
			"<leader>wx",
			function()
				require("persistence").stop()
			end,
			desc = "Don't Save Session",
		},
	},
}
