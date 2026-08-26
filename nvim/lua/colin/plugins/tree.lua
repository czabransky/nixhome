local M = {}

local function setup_netrw(val)
	-- Set to 0 if you're using float.enable = true, otherwise NetRW will appear on startup in non-floating mode.
	-- This may or may not be desirable. If you are also using something like mini.starter, then NetRW plugins will interfere.
	vim.g.loaded_netrw = val
	vim.g.loaded_netrwPlugin = val
end

function M.nvimtree()
	return {
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			{ "nvim-tree/nvim-web-devicons" },
		},
		config = function()
			require("nvim-tree").setup({
				git = {
					ignore = true, -- git files available in telescope
				},
				view = {
					side = "right",
					float = {
						-- Set enable to true if prefer a floating file explorer.
						enable = true,
						-- nvim-tree only registers its WinLeave auto-close
						-- autocmd once, at this setup() call, gated on
						-- float.enable + quit_on_focus_loss both being true
						-- at THIS moment - it never re-checks later. Since
						-- float starts true, leaving quit_on_focus_loss at
						-- its true default means "close on focus loss" stays
						-- registered forever, even after <leader>el switches
						-- to docked. False here means it's never registered
						-- at all, so the tree stays open in either mode.
						quit_on_focus_loss = false,
						open_win_config = {
							width = 100,
						},
					},
					width = 50,
				},
				actions = {
					open_file = {
						-- Only makes sense while floating (view.float.enable
						-- above starts true) - a docked sidebar should stay
						-- open like a persistent explorer. <leader>el below
						-- flips this to match whenever it toggles float/docked.
						quit_on_open = true,
					},
				},
				renderer = {
					icons = {
						git_placement = "after",
						web_devicons = {
							folder = {
								enable = true,
							},
						},
					},
					indent_markers = {
						enable = false,
					},
				},
			})
			local api = require("nvim-tree.api")
			vim.keymap.set("n", "<leader>ee", api.tree.toggle, { desc = "Explorer Toggle" })
			vim.keymap.set("n", "<leader>er", function()
				api.tree.find_file({ open = true, focus = true })
			end, { desc = "Explorer Reveal File" })

			-- view.open() only ever reads the live config, so flipping
			-- float.enable here and re-opening switches between floating
			-- and docked - no plugin support for this beyond that.
			local tree_config = require("nvim-tree.config")
			vim.keymap.set("n", "<leader>el", function()
				local was_open = api.tree.is_visible()
				tree_config.g.view.float.enable = not tree_config.g.view.float.enable
				tree_config.g.actions.open_file.quit_on_open = tree_config.g.view.float.enable
				if was_open then
					api.tree.close()
					api.tree.find_file({ open = true, focus = true })
				end
				vim.notify("nvim-tree: " .. (tree_config.g.view.float.enable and "floating" or "docked"))
			end, { desc = "Explorer Toggle Float/Docked" })
			setup_netrw(0)

			-- Docked nvim-tree windows ARE captured by :mksession (floating
			-- ones are not - Neovim's session format skips floats entirely).
			-- On restore, the window is recreated with a plain `file
			-- NvimTree_1` command since nvim-tree's own buffer setup never
			-- runs, leaving a normal listed buffer named "NvimTree_1" that
			-- shows up as a bufferline tab. Closing the tree before
			-- persistence.nvim saves avoids serializing it at all.
			vim.api.nvim_create_autocmd("User", {
				pattern = "PersistenceSavePre",
				callback = function()
					if api.tree.is_visible() then
						api.tree.close()
					end
				end,
			})
		end,
	}
end

function M.neotree()
	return {
		"nvim-neo-tree/neo-tree.nvim",
		version = "v3.x",
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-tree/nvim-web-devicons" },
			{ "MunifTanjim/nui.nvim" },
		},
		config = function()
			require("neo-tree").setup({
				default_component_configs = {
					container = {
						enable_character_fade = true,
					},
				},
				enable_diagnostics = true,
				enable_git_status = true,
				popup_border_style = "rounded",
			})
			vim.keymap.set("n", "<leader>e", "<cmd>Neotree<CR>", { desc = "Explorer Toggle" })
			setup_netrw(1)
		end,
	}
end

function M.oil()
	return {
		"stevearc/oil.nvim",
		opts = {},
		dependencies = {
			{ "nvim-tree/nvim-web-devicons" },
		},
		config = function()
			require("oil").setup({
				win_options = {
					signcolumn = "yes",
				},
			})
			vim.keymap.set("n", "<leader>e", function()
				return require("oil").toggle_float()
			end, { desc = "Explorer Toggle" })
			vim.keymap.set("n", "<leader>E", function()
				return require("oil").open_float()
			end, { desc = "Explorer Reveal File" })
		end,
	}
end

return M
