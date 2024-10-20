local M = {}

function M.blinkcmp() 
	return {
		'saghen/blink.cmp',
		lazy = false, 
		dependencies = 'rafamadriz/friendly-snippets',
		version = 'v0.*',
		opts = {
			highlight = { use_nvim_cmp_as_default = true, },
			nerd_font_variant = 'normal',
		}
	}
end

function M.nvimcmp()
	return {
		'hrsh7th/nvim-cmp',
		dependencies = {
			{ 'hrsh7th/cmp-nvim-lsp' },
			{ 'hrsh7th/cmp-buffer' },
			{ 'hrsh7th/cmp-path' },
			{ 'onsails/lspkind.nvim' },
			{ 'saadparwaiz1/cmp_luasnip' },
			{ 'L3MON4D3/LuaSnip' },
		},
		config = function()
			local cmp = require('cmp')
			local luasnip = require('luasnip')
			local lspkind = require('lspkind')

			-- Load Snippets
			require('luasnip.loaders.from_vscode').lazy_load()

			-- Configure Auto Completion
			local types = require('cmp.types')
			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					['<C-n>'] = {
						i = function()
							if cmp.visible() then
								cmp.select_next_item({ behavior = types.cmp.SelectBehavior.Insert })
							else
								cmp.complete()
							end
						end,
					},
					['<C-e>'] = {
						i = function()
							if cmp.visible() then
								cmp.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert })
							else
								cmp.complete()
							end
						end,
					},
					['<C-d>'] = {
						i = function(fallback)
							if cmp.visible() then
								cmp.scroll_docs(4)
							else
								fallback()
							end
						end,
					},
					['<C-u>'] = {
						i = function(fallback)
							if cmp.visible() then
								cmp.scroll_docs(-4)
							else
								fallback()
							end
						end,
					},
					['<C-Space>'] = cmp.mapping.complete({}), -- Open Completion Suggestion
					['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept Suggestion
					['<Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { 'i', 's' }),
					['<S-Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { 'i', 's' }),
					['<C-c>'] = cmp.mapping.abort(), -- Close Suggestions
				}),
				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					{ name = 'dap' },
					{ name = 'buffer',                 max_item_count = 5 },
					{ name = 'path',                   max_item_count = 3 },
					{ name = 'luasnip',                max_item_count = 3 },
					{ name = 'vim-dadbod-completion',  max_item_count = 5 },
					{ name = "nvim_lsp_signature_help" },
				}),

				formatting = {
					expandable_indicator = true,
					format = lspkind.cmp_format({
						node = 'symbol_text',
						maxwidth = 50,
						ellipsis_char = '...',
					}),
					fields = { 'abbr', 'kind', 'menu' },
				},
				experimental = {
					ghost_text = false,
				}
			})
		end
	}
end

return M
