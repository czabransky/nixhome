-- https://github.com/danymat/neogen
-- Generates doc-comment skeletons from the actual function/class signature
-- via Treesitter. C#'s default convention is "doxygen" - override to
-- "xmldoc" for real .NET-style /// <summary>/<param>/<returns> comments.
return {
	"danymat/neogen",
	dependencies = "nvim-treesitter/nvim-treesitter",
	config = function()
		require("neogen").setup({
			languages = {
				cs = {
					template = {
						annotation_convention = "xmldoc",
					},
				},
			},
		})
		vim.keymap.set("n", "<leader>cd", function()
			require("neogen").generate()
		end, { desc = "[C]ode [D]oc Comment" })
	end,
}
