return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
	},
	config = function()
		local actions = require("telescope.actions")
		require("telescope").setup({
			defaults = {
				path_display = { "truncate" },
				cache_picker = {
					num_pickers = 20,
				},
				file_ignore_patterns = {
					"^%.git/",
					"^node_modules/",
					"^dist/",
					"^build/",
					"^target/",
					"^bin/",
					"^obj/",
				},
				mappings = {
					i = {
						["<C-u>"] = true,
						["<C-d>"] = true,
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
						["<C-q>"] = actions.smart_add_to_qflist + actions.open_qflist,
					},
				},
				layout_strategy = "flex",
				layout_config = {
					prompt_position = "top",
					flex = { flip_columns = 140 },
					horizontal = {
						mirror = false,
						preview_width = 0.55,
					},
					vertical = { mirror = false },
				},
				dynamic_preview_title = true,
				sorting_strategy = "ascending",
			},
			pickers = {
				find_files = {
					hidden = true,
					follow = true,
				},
				live_grep = {
					additional_args = function()
						return { "--hidden", "--glob", "!**/.git/*" }
					end,
				},
			},
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
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
		vim.keymap.set("n", "<leader>sF", find_all_files, { desc = "Search All Files" })
		vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "Search Telescope Pickers" })
		vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "Search Commands" })
		vim.keymap.set("n", "<leader>s/", live_grep_open_files, { desc = "Search / in Open Files" })
		vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search Files With Grep" })
		vim.keymap.set("n", "<leader>sG", builtin.git_files, { desc = "Search Git Files" })
		vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Search Current Word" })
		vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "Search Resume from Previous State" })
		vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search Keymaps" })
		vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Search Open Buffers" })
		vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search Diagnostics" })
		vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search Help" })
	end,
}
