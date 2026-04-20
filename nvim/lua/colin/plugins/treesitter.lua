return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufEnter" },
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter-textobjects" },
		{ "windwp/nvim-ts-autotag" },
	},
	config = function()
		local uv = vim.uv or vim.loop
		require("nvim-treesitter.configs").setup({
			auto_install = true,
			ensure_installed = {
				"bash",
				"css",
				"lua",
				"markdown",
				"markdown_inline",
				"nix",
				"html",
				"javascript",
				"json",
				"jsonc",
				"c_sharp",
				"typescript",
				"tsx",
				"vim",
				"vimdoc",
				"xml",
			},
			highlight = {
				enable = true,
				use_languagetree = true,
				additional_vim_regex_highlighting = false,
				disable = function(_, bufnr)
					local max_filesize = 200 * 1024
					local ok, stats = pcall(uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
					if ok and stats and stats.size > max_filesize then
						return true
					end
					return false
				end,
			},
			ignore_install = {},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "gnn", -- set to `false` to disable one of the mappings
					node_incremental = "grn",
					scope_incremental = "grc",
					node_decremental = "grm",
				},
			},
			indent = { enable = true },
			autotag = {
				enable = true,
				enable_rename = true,
				enable_close = true,
				enable_close_on_slash = true,
				filetypes = { "html", "xml", "tsx", "javascript", "typescript", "javascriptreact", "typescriptreact" },
			},
			modules = {},
			sync_install = false,
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["aa"] = "@parameter.outer",
						["ia"] = "@parameter.inner",
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]a"] = "@parameter.outer",
						["]m"] = "@function.outer",
						["]]"] = "@class.outer",
					},
					goto_next_end = {
						["]A"] = "@parameter.outer",
						["]M"] = "@function.outer",
						["]["] = "@class.outer",
					},
					goto_previous_start = {
						["[a"] = "@parameter.outer",
						["[m"] = "@function.outer",
						["[["] = "@class.outer",
					},
					goto_previous_end = {
						["[A"] = "@parameter.outer",
						["[M"] = "@function.outer",
						["[]"] = "@class.outer",
					},
					goto_next = {
						["]f"] = "@function.outer",
					},
					goto_previous = {
						["[f"] = "@function.outer",
					},
				},
			},
		})
	end,
}
