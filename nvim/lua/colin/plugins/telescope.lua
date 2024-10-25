return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
	},
	config = function()
		require("telescope").setup({
			defaults = {
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-u>"] = true,
						["<C-d>"] = true,
						["<C-j>"] = require("telescope.actions").move_selection_next,
						["<C-k>"] = require("telescope.actions").move_selection_previous,
						["<C-q>"] = require("telescope.actions").smart_add_to_qflist
							+ require("telescope.actions").open_qflist,
					},
				},
				layout_strategy = "horizontal",
				layout_config = {
					prompt_position = "top",
					horizontal = { mirror = false },
					vertical = { mirror = false },
				},
				sorting_strategy = "ascending",
			},
		})

		pcall(require("telescope").load_extension, "fzf")

		local builtin = require("telescope.builtin")

		local function find_all_files()
			builtin.find_files({
				prompt_title = "Search Files",
				hidden = true,
				find_command = {
					"rg",
					"--files",
					"-uu",
					"-g",
					"!.git",
					"-g",
					"!lib/",
					"-g",
					"!__pycache__/",
					"-g",
					"!venv/",
				},
			})
		end

		local function live_grep_open_files()
			builtin.live_grep({
				grep_open_files = true,
				prompt_title = "Live Grep in Open Files",
			})
		end

		vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Search Files" })
		vim.keymap.set("n", "<leader>st", builtin.builtin, { desc = "Search Telescpe Builtin" })
		vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "Search Commands" })
		vim.keymap.set("n", "<leader>s/", live_grep_open_files, { desc = "Search / in Open Files" })
		vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search Files With Grep" })
		vim.keymap.set("n", "<leader>sa", find_all_files, { desc = "Search All Files" })
		vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Search Current Word" })
		vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "Search Resume from Previous State" })
		vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Search Open Buffers" })
		vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search Diagnostics" })
		vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search Help" })
		vim.keymap.set("n", "<leader>gf", builtin.git_files, { desc = "Search Git Files" })
	end,
}
