local M = {}

M.on_attach = function(client, bufnr)
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end
	nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	nmap("<leader>cr", vim.lsp.buf.rename, "[C]ode [R]ename")
	nmap("<leader>co", function()
		-- "source.organizeImports" matches any server's more specific kind
		-- (e.g. biome's "source.organizeImports.biome") per the LSP spec's
		-- dot-separated CodeActionKind hierarchy.
		vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
	end, "[C]ode [O]rganize Imports")
	nmap("<leader>ce", function()
		-- Generic "source.fixAll" so this keeps working across whichever
		-- formatter/linter is actually attached (biome today, eslint before).
		vim.lsp.buf.code_action({ context = { only = { "source.fixAll" } }, apply = true })
	end, "[C]ode Fix All")
	-- :LspRestart/:LspInfo (nvim-lspconfig's legacy commands) no longer exist:
	-- Neovim 0.11+ ships a native :lsp command (enable/disable/restart/stop),
	-- and nvim-lspconfig deliberately skips defining its own once it detects
	-- that's present. :lsp restart with no args restarts every client
	-- attached to the current buffer, same semantics as the old :LspRestart.
	nmap("<leader>cR", "<cmd>lsp restart<cr>", "[C]ode LSP [R]estart")
	nmap("<leader>cL", "<cmd>checkhealth vim.lsp<cr>", "[C]ode [L]SP Info")
	nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
	nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	-- Alias for Neovim's newer default gr* convention (grn/gra/grr/gri), which
	-- this config never adopted. Without it, typing "grr" fires "gr" on the
	-- 2nd key (nothing else shares that prefix) and leaves a stray "r" -
	-- normal-mode "replace char" - waiting to swallow whatever key comes next.
	-- (Confirmed: the ~1s latency here is Roslyn's own response time, not
	-- Telescope overhead - plain vim.lsp.buf.references() was just as slow.
	-- Use <C-q> in the picker to send results to the quickfix list.)
	nmap("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	nmap("gi", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
	-- Call hierarchy (standard LSP callHierarchy/incomingCalls|outgoingCalls).
	-- No read/write/assignment classification exists at this level - that's
	-- only available per-buffer via textDocument/documentHighlight.
	nmap("<leader>ch", require("telescope.builtin").lsp_incoming_calls, "[C]alls Incoming (callers)")
	nmap("<leader>cH", require("telescope.builtin").lsp_outgoing_calls, "[C]alls Outgoing (callees)")
	nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
	nmap("<leader>ss", require("telescope.builtin").lsp_document_symbols, "[S]earch [S]ymbols")
	nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
	nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
	nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
	nmap("<leader>wl", function()
		vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "[W]orkspace [L]ist Folders")
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

	if client and client.supports_method and client:supports_method("textDocument/inlayHint") then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		nmap("<leader>ci", function()
			local enabled = false
			local ok, result = pcall(vim.lsp.inlay_hint.is_enabled, { bufnr = bufnr })
			if ok then
				enabled = result
			end
			vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
		end, "[C]ode Toggle [I]nlay Hints")
	end
end
return M
