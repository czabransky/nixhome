 return {
	 'echasnovski/mini.nvim',
	 version = '*',
	 config = function()
		 require("mini.animate").setup({
			 cursor = { timing = function(_, n) return 100 / n end, },
			 scroll = { timing = function(_, n) return 100 / n end, },
		 })
	 end
 }
