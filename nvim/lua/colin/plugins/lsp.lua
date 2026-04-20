return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"williamboman/mason.nvim",
			config = true,
			opts = {
				registries = {
					"github:mason-org/mason-registry",
					"github:Crashdummyy/mason-registry",
				},
			},
		},
		{ "williamboman/mason-lspconfig.nvim" },
	},
	config = function()
		-- Modify some aesthetics of the LSP popup window.
		-- vim.opt.winhighlight = require('cmp').config.window.bordered().winhighlight
		local border = "rounded"
		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border })
		vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })
		vim.diagnostic.config({
			float = { border = border },
			virtual_text = true,
			signs = true,
			update_in_insert = false,
			underline = true,
			severity_sort = true,
		})

		-- [[ LSP Attach to Buffer ]]
		-- Must define a unique buffer name so multiple buffers can attach at the same time
		-- local augroups = {}
		-- local get_augroup = function(client)
		-- 	if not augroups[client.id] then
		-- 		local name = "UserLspAttach" .. client.name
		-- 		local id = vim.api.nvim_create_augroup(name, { clear = true })
		-- 		augroups[client.id] = id
		-- 	end
		-- 	return augroups[client.id]
		-- end

		local format_group = vim.api.nvim_create_augroup("UserLspFormat", { clear = true })
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
			callback = function(args)
				local bufnr = args.buf
				vim.api.nvim_clear_autocmds({ group = format_group, buffer = bufnr })
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = format_group,
					buffer = bufnr,
					callback = function(ev)
						require("conform").format({ bufnr = ev.buf, lsp_format = "fallback" })
					end,
				})
				-- vim.api.nvim_create_autocmd('BufWritePre', {
				-- 	group = get_augroup(client),
				-- 	buffer = bufnr,
				-- 	callback = function()
				-- 		vim.lsp.buf.format {
				-- 			async = false,
				-- 			filter = function(c)
				-- 				return c.id == client.id
				-- 			end
				-- 		}
				-- 	end
				-- })
			end,
		})

		require("colin.lsp")
	end,
}
