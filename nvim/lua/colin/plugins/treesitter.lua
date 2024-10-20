return {
	'nvim-treesitter/nvim-treesitter',
	build = ':TSUpdate',
	event = { 'BufEnter' },
	dependencies = {
		{ 'nvim-treesitter/nvim-treesitter-textobjects' },
	},
	config = function()
		require('nvim-treesitter.configs').setup {
			auto_install = true,
			ensure_installed = {
				'lua',
				'markdown',
				'markdown_inline',
				'nix',
				'typescript',
				'vim',
				'vimdoc',
				'xml',
			},
			highlight = {
				enable = true,
				use_languagetree = true,
			},
			ignore_install = {},
			indent = { enable = true },
			autotag = {
				enable = true,
				enable_rename = true,
				enable_close = true,
				enable_close_on_slash = true,
				filetypes = { "html", "xml", "tsx", "js", "ts", "jsx" },
			},
			modules = {},
			sync_install = true,
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						['aa'] = '@parameter.outer',
						['ia'] = '@parameter.inner',
						['af'] = '@function.outer',
						['if'] = '@function.inner',
						['ac'] = '@class.outer',
						['ic'] = '@class.inner',
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						[']m'] = '@function.outer',
						[']]'] = '@class.outer',
					},
					goto_next_end = {
						[']M'] = '@function.outer',
						[']['] = '@class.outer',
					},
					goto_previous_start = {
						['[m'] = '@function.outer',
						['[['] = '@class.outer',
					},
					goto_previous_end = {
						['[M'] = '@function.outer',
						['[]'] = '@class.outer',
					},
					goto_next = {
						[']f'] = '@function.outer',
					},
					goto_previous = {
						['[f'] = '@function.outer',
					},
				},
			}
		}
	end
}
