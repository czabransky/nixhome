local M = {}

local function has_rooted_roslyn_client(bufnr, exclude_id)
	for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "roslyn" })) do
		if c.id ~= exclude_id and c.config and c.config.root_dir and c.config.root_dir ~= "" then
			return true
		end
	end

	return false
end

M.on_attach = function(client, bufnr)
	if client and client.name == "roslyn" then
		local root = client.config and client.config.root_dir
		if not root or root == "" then
			if has_rooted_roslyn_client(bufnr, client.id) then
				vim.schedule(function()
					client:stop(true)
					vim.notify("Stopped duplicate roslyn client without root_dir.", vim.log.levels.INFO)
				end)
				return
			end

			vim.schedule(function()
				vim.notify(
					"Roslyn attached without root_dir. Run :Roslyn target and :Roslyn restart.",
					vim.log.levels.WARN
				)
			end)
		end
	end

	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end
	nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
	nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	nmap("gi", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
	nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
	nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
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
		nmap("<leader>th", function()
			local enabled = false
			local ok, result = pcall(vim.lsp.inlay_hint.is_enabled, { bufnr = bufnr })
			if ok then
				enabled = result
			end
			vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
		end, "[T]oggle Inlay [H]ints")
	end
end
return M
