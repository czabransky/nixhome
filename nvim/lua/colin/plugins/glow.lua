return {
	"ellisonleao/glow.nvim",
	cmd = "Glow",
	config = function()
		require('glow').setup({
			border = 'rounded',
			style = "dark",
			width = 150,
			width_ratio = 0.9,
			height_ratio = 0.9,
		})
	end,
}
