return {
	"folke/noice.nvim",
	dependencies = {
		{ "MunifTanjim/nui.nvim" },
		{ "rcarriga/nvim-notify" },
	},
	event = "VeryLazy",
	opts = {},
	config = function()
		require("noice").setup({
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
				message = { enable = false },
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = false, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = true, -- add a border to hover docs and signature help
			},
			messages = { enabled = false },
			views = {
				mini = {
					win_options = {
						winblend = 0,
					},
				},
			},
		})
		vim.keymap.set({ "n", "i", "s" }, "<c-s>", function()
			if not require("noice.lsp").scroll(4) then
				return "<c-s>"
			end
		end, { silent = true, expr = true })

		vim.keymap.set({ "n", "i", "s" }, "<c-f>", function()
			if not require("noice.lsp").scroll(-4) then
				return "<c-f>"
			end
		end, { silent = true, expr = true })
	end,
}
