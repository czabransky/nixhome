 return {
	 'echasnovski/mini.nvim',
	 version = '*',
	 config = function()
		 require("mini.animate").setup({
			 cursor = { enable = false, timing = function(_, n) return 100 / n end, },
			 scroll = { enable = false, timing = function(_, n) return 100 / n end, },
		 })
		 require("mini.notify").setup()
	 end
 }
