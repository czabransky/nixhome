return {
	'folke/which-key.nvim',
	event = "VeryLazy",
	opts = {},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
	config = function()
		local wk = require('which-key')
		wk.add({
			{ "<leader>c",  group = "Code",                           nowait = true,                    remap = false },
			{ "<leader>d",  group = "Document",                       nowait = true,                    remap = false },
			{ "<leader>g",  group = "Git",                            nowait = true,                    remap = false },
			{ "<leader>h",  group = "Harpoon",                        nowait = true,                    remap = false },
			{ "<leader>s",  group = "Search",                         nowait = true,                    remap = false },
			{ "<leader>t",  group = "Toggle",                         nowait = true,                    remap = false },
--			{ "<leader>tb", "<cmd>DBUIToggle<CR>",                    desc = "Toggle Dadbod UI",        nowait = true, remap = false },
--			{ "<leader>td", "<cmd>lua require('dapui').toggle()<CR>", desc = "Toggle DAP UI",           nowait = true, remap = false },
			{ "<leader>tg", "<cmd>Glow<CR>",                          desc = "Toggle Glow",             nowait = true, remap = false },
--			{ "<leader>tm", "<cmd>MarkdownPreview<CR>",               desc = "Toggle Markdown Preview", nowait = true, remap = false },
			{ "<leader>w",  group = "Workspace",                      nowait = true,                    remap = false },
		})
	end,
}
