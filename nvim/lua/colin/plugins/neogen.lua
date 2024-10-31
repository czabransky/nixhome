-- https://github.com/danymat/neogen
return {
	"danymat/neogen",
	version = "*",
	config = function()
		require("neogen").setup({
			snippet_engine = "luasnip",
			languages = {
				cs = {
					template = {
						annotation_convention = "xmldoc",
					},
				},
			},
		})
	end,
}
