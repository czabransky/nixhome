return {
	"cbochs/grapple.nvim",
	dependencies = {
		{ "nvim-tree/nvim-web-devicons", lazy = true },
	},
	opts = {
		scope = "git", -- also try out "git_branch"
	},
	event = { "BufReadPost", "BufNewFile" },
	cmd = "Grapple",
	keys = {
		{ "<leader>a", "<cmd>Grapple toggle<cr>", desc = "Mark Toggle" },
		{ "<leader>m", "<cmd>Grapple toggle_tags<cr>", desc = "Mark List" },
		{ "]t", "<cmd>Grapple cycle_tags next<cr>", desc = "Mark Next" },
		{ "[t", "<cmd>Grapple cycle_tags prev<cr>", desc = "Mark Previous" },
	},
}
