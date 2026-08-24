local ensure_installed = {
	"bash",
	"css",
	"lua",
	"markdown",
	"markdown_inline",
	"nix",
	"html",
	"javascript",
	"json",
	"c_sharp",
	"typescript",
	"tsx",
	"vim",
	"vimdoc",
	"xml",
}

local function under_max_filesize(bufnr)
	local max_filesize = 200 * 1024
	local uv = vim.uv or vim.loop
	local ok, stats = pcall(uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
	if ok and stats and stats.size > max_filesize then
		return false
	end
	return true
end

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			branch = "main",
			init = function()
				vim.g.no_plugin_maps = true
			end,
			config = function()
				require("nvim-treesitter-textobjects").setup({
					select = { lookahead = true },
					move = { set_jumps = true },
				})

				local select = require("nvim-treesitter-textobjects.select")
				local move = require("nvim-treesitter-textobjects.move")
				local swap = require("nvim-treesitter-textobjects.swap")

				local function map_select(lhs, query)
					vim.keymap.set({ "x", "o" }, lhs, function()
						select.select_textobject(query, "textobjects")
					end)
				end

				map_select("aa", "@parameter.outer")
				map_select("ia", "@parameter.inner")
				map_select("af", "@function.outer")
				map_select("if", "@function.inner")
				map_select("ac", "@class.outer")
				map_select("ic", "@class.inner")

				local function map_move(lhs, fn, query)
					vim.keymap.set({ "n", "x", "o" }, lhs, function()
						fn(query, "textobjects")
					end)
				end

				map_move("]a", move.goto_next_start, "@parameter.outer")
				map_move("]m", move.goto_next_start, "@function.outer")
				map_move("]]", move.goto_next_start, "@class.outer")
				map_move("]A", move.goto_next_end, "@parameter.outer")
				map_move("]M", move.goto_next_end, "@function.outer")
				map_move("][", move.goto_next_end, "@class.outer")
				map_move("[a", move.goto_previous_start, "@parameter.outer")
				map_move("[m", move.goto_previous_start, "@function.outer")
				map_move("[[", move.goto_previous_start, "@class.outer")
				map_move("[A", move.goto_previous_end, "@parameter.outer")
				map_move("[M", move.goto_previous_end, "@function.outer")
				map_move("[]", move.goto_previous_end, "@class.outer")
				map_move("]f", move.goto_next, "@function.outer")
				map_move("[f", move.goto_previous, "@function.outer")

				vim.keymap.set("n", "<leader>pl", function()
					swap.swap_next("@parameter.inner")
				end, { desc = "Swap Parameter Right" })
				vim.keymap.set("n", "<leader>ph", function()
					swap.swap_previous("@parameter.inner")
				end, { desc = "Swap Parameter Left" })
			end,
		},
		{
			"windwp/nvim-ts-autotag",
			config = function()
				require("nvim-ts-autotag").setup({
					opts = {
						enable_close = true,
						enable_rename = true,
						enable_close_on_slash = true,
					},
				})
			end,
		},
	},
	config = function()
		require("nvim-treesitter").install(ensure_installed)

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				if not under_max_filesize(args.buf) then
					return
				end
				pcall(vim.treesitter.start, args.buf)
				require("colin.core.indent").apply_current(args.buf)
				vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.wo[0][0].foldmethod = "expr"
			end,
		})
	end,
}
