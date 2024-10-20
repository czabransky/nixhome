local M = {}

function M.catppuccin()
	return {
		'catppuccin/nvim',
		name = 'catppuccin',
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = 'frappe'
			})
			vim.cmd.colorscheme 'catppuccin'
		end
	}
end

function M.everforest()
	return {
		"neanias/everforest-nvim",
		version = false,
		lazy = false,
		priority = 1000,
		config = function()
			vim.g.everforest_terminal_colors = 1
			vim.g.everforest_background = 'medium'
			vim.g.everforest_enable_italic = 1
			vim.g.everforest_better_performance = 1
			vim.g.everforest_cursor = 'aqua'
			vim.cmd [[colorscheme everforest]]
		end
	}
end

function M.gruvbox()
	return {
		'morhetz/gruvbox',
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme 'gruvbox'
		end
	}
end

function M.kanagawa()
	return {
		'rebelot/kanagawa.nvim',
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd.colorscheme 'kanagawa-wave'
		end
	}
end

function M.onedark()
	return {
		'navarasu/onedark.nvim',
		lazy = false,
		priority = 1000,
		config = function()
			require('onedark').setup {
				style = 'dark',
				toggle_style_key = '<leader>ts',
			}
			vim.cmd.colorscheme 'onedark'
		end
	}
end

function M.tokyonight()
	return {
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1001,
		opts = {},
		config = function()
			vim.cmd.colorscheme 'tokyonight-night'
		end
	}
end

return M
