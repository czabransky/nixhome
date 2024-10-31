return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "williamboman/mason.nvim", config = true },
		{ "williamboman/mason-lspconfig.nvim" },
	},
	config = function()
		-- Modify some aesthetics of the LSP popup window.
		-- vim.opt.winhighlight = require('cmp').config.window.bordered().winhighlight
		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
		vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
		vim.diagnostic.config({
			float = { border = "rounded" },
			virtual_text = true,
			signs = true,
			update_in_insert = true,
			underline = true,
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

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
			callback = function(args)
				local client_id = args.data.client_id
				local client = vim.lsp.get_client_by_id(client_id)
				-- local bufnr = args.buf
				if not client.server_capabilities.documentFormattingProvider then
					return
				end
				vim.api.nvim_create_autocmd("BufWritePre", {
					pattern = "*",
					callback = function(ev)
						require("conform").format({ bufnr = ev.buf })
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
	end,
}
