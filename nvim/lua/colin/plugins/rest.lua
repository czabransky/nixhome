-- https://github.com/rest-nvim/rest.nvim
-- HTTP client for .http files (JetBrains .http spec), replacing kulala.nvim
-- (see plugins/archive/kulala.lua) which wasn't working reliably. No .setup()
-- call - it's configured entirely through the vim.g.rest_nvim table, read
-- when a .http buffer first loads the plugin.
--
-- Needs the tree-sitter "http" parser (ensure_installed in
-- plugins/treesitter.lua) - rest.nvim parses requests via treesitter, not a
-- custom lexer.
return {
	"rest-nvim/rest.nvim",
	ft = "http",
	cmd = "Rest",
	keys = {
		{ "<leader>Rs", "<cmd>Rest run<cr>", desc = "[R]equest [S]end" },
		{ "<leader>Rl", "<cmd>Rest last<cr>", desc = "[R]equest Rerun [L]ast" },
		{ "<leader>Ro", "<cmd>Rest open<cr>", desc = "[R]equest [O]pen Window" },
		{ "<leader>Re", "<cmd>Rest env select<cr>", desc = "[R]equest Select [E]nvironment" },
		{ "<leader>Rv", "<cmd>Rest env show<cr>", desc = "[R]equest [V]iew Environment" },
		{ "<leader>Ry", "<cmd>Rest curl yank<cr>", desc = "[R]equest Cop[y] As cURL" },
	},
	config = function()
		vim.g.rest_nvim = {
			env = {
				enable = true,
				pattern = "%.env.*",
			},
			ui = {
				winbar = true,
			},
		}
	end,
}
