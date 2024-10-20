local M = {}

local function setup_netrw(val)
	-- Set to 0 if you're using float.enable = true, otherwise NetRW will appear on startup in non-floating mode.
	-- This may or may not be desirable. If you are also using something like mini.starter, then NetRW plugins will interfere.
	vim.g.loaded_netrw = val
	vim.g.loaded_netrwPlugin = val
end

function M.nvimtree()
	return {
		'nvim-tree/nvim-tree.lua',
		dependencies = {
			{ 'nvim-tree/nvim-web-devicons' },
		},
		config = function()
			require('nvim-tree').setup({
				git = {
					ignore = true, -- git files available in telescope
				},
				view = {
					side = 'right',
					float = {
						-- Set enable to true if prefer a floating file explorer.
						enable = true,
						open_win_config = {
							width = 100,
						},
					},
					width = 50,
				},
				renderer = {
					icons = {
						git_placement = 'after',
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
			vim.keymap.set('n', '<leader>tt',
				function() return require('nvim-tree.api').tree.toggle({ find_file = true }) end,
				{ desc = 'Toggle Tree' })
			setup_netrw(0)
		end
	}
end

function M.neotree()
	return {
		'nvim-neo-tree/neo-tree.nvim',
		version = 'v3.x',
		requires = {
			{ 'nvim-lua/plenary.nvim' },
			{ 'nvim-tree/nvim-web-devicons' },
			{ 'MunifTanjim/nui.nvim' },
		},
		config = function()
			require('neo-tree').setup({
				default_component_configs = {
					container = {
						enable_character_fade = true,
					},
				},
				enable_diagnostics = true,
				enable_git_status = true,
				popup_border_style = 'rounded',
			})
			vim.keymap.set('n', '<leader>tt', '<cmd>Neotree<CR>', { desc = 'Toggle Tree' })
			setup_netrw(1)
		end,
	}
end

function M.oil()
	return {
		'stevearc/oil.nvim',
		opts = {},
		dependencies = {
			{ 'nvim-tree/nvim-web-devicons' },
		},
		config = function()
			require('oil').setup({
				win_options = {
					signcolumn = 'yes',
				},
			})
			vim.keymap.set('n', '<leader>tt', function() return require('oil').toggle_float() end,
				{ desc = 'Toggle Tree' })
			vim.keymap.set('n', '<leader>te', function() return require('oil').toggle_float() end,
				{ desc = 'Oil Explorer' })
		end
	}
end

return M
