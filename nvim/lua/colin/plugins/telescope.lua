return {
	"nvim-telescope/telescope.nvim",
	branch = "master",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		"nvim-telescope/telescope-fzf-native.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
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
				preview = {
					treesitter = false,
				},
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
				-- Without this, vim.ui.select() (code actions, lsp_implementations
				-- picks, etc.) falls back to Neovim's bare default: a numbered
				-- list dumped in the message area where you type a digit + <CR> -
				-- no arrow-key selection at all. This routes it through Telescope
				-- instead, "cursor" theme for a small tooltip-like popup at the
				-- cursor rather than a full-screen picker.
				-- get_cursor()'s own default height (9) only fits ~5 visible
				-- result rows once the prompt line and borders are subtracted.
				["ui-select"] = require("telescope.themes").get_cursor({
					layout_config = { height = 15 },
				}),
			},
		})

		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")

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
		vim.keymap.set("n", "<leader>sC", builtin.commands, { desc = "Search Commands" })
		vim.keymap.set("n", "<leader>s/", live_grep_open_files, { desc = "Search / in Open Files" })
		vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search Files With Grep" })
		vim.keymap.set("n", "<leader>sG", builtin.git_files, { desc = "Search Git Files" })
		vim.keymap.set("n", "<leader>sc", builtin.git_status, { desc = "Search Git Status (Changed Files)" })
		vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Search Current Word" })
		vim.keymap.set("n", "<leader>sr", builtin.oldfiles, { desc = "Search Recent Files" })
		vim.keymap.set("n", "<leader>sp", builtin.resume, { desc = "Search Previous (Resume State)" })
		vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search Keymaps" })
		vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Search Open Buffers" })
		vim.keymap.set("n", "<leader>sx", builtin.diagnostics, { desc = "Search Diagnostics" })
		vim.keymap.set("n", "<leader>se", function()
			builtin.diagnostics({ severity = vim.diagnostic.severity.ERROR })
		end, { desc = "Search Diagnostics (Errors Only)" })
		vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search Help" })
		vim.keymap.set("n", "<leader>sT", function()
			require("colin.plugins.theme").picker()
		end, { desc = "Search Themes" })
	end,
}
