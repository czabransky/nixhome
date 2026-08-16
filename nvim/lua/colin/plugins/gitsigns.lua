-- https://github.com/lewis6991/gitsigns.nvim
return {
	"lewis6991/gitsigns.nvim",
	config = function()
		require("gitsigns").setup({
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end

				map("n", "]c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
						return
					end
					gs.next_hunk()
				end, "Next Hunk")

				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
						return
					end
					gs.prev_hunk()
				end, "Previous Hunk")

				map("n", "<leader>gs", gs.stage_hunk, "Hunk Stage")
				map("n", "<leader>gr", gs.reset_hunk, "Hunk Reset")
				map("v", "<leader>gs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Hunk Stage")
				map("v", "<leader>gr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Hunk Reset")
				map("n", "<leader>gS", gs.stage_buffer, "Buffer Stage")
				map("n", "<leader>gR", gs.reset_buffer, "Buffer Reset")
				map("n", "<leader>gp", gs.preview_hunk, "Hunk Preview")
				map("n", "<leader>gb", function()
					gs.blame_line({ full = true })
				end, "Blame Line")
				map("n", "<leader>gu", gs.undo_stage_hunk, "Hunk Undo Stage")
				map("n", "<leader>gt", gs.toggle_deleted, "Hunk Toggle Deleted")
			end,
		})
	end,
}
