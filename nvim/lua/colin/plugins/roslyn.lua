local function has_rooted_roslyn_client(bufnr, exclude_id)
	for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "roslyn" })) do
		if c.id ~= exclude_id and c.config and c.config.root_dir and c.config.root_dir ~= "" then
			return true
		end
	end

	return false
end

local function set_roslyn_keymaps(bufnr)
	local nmap = function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
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
end

local function handle_roslyn_attach(client, bufnr)
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
			vim.notify("Roslyn attached without root_dir. Run :Roslyn target and :Roslyn restart.", vim.log.levels.WARN)
		end)
	end

	set_roslyn_keymaps(bufnr)

	if client.supports_method and client:supports_method("textDocument/inlayHint") then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		vim.keymap.set("n", "<leader>th", function()
			local enabled = false
			local ok, result = pcall(vim.lsp.inlay_hint.is_enabled, { bufnr = bufnr })
			if ok then
				enabled = result
			end
			vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
		end, { buffer = bufnr, desc = "LSP: [T]oggle Inlay [H]ints" })
	end
end

return {
	"seblyng/roslyn.nvim",
	ft = { "cs", "razor", "cshtml" },
	dependencies = { "williamboman/mason-lspconfig.nvim" },
	---@module 'roslyn.config'
	---@type RoslynNvimConfig
	opts = {
		filewatching = "roslyn",
		broad_search = true,
		lock_target = false,
		choose_target = function(targets)
			if not targets or #targets == 0 then
				return nil
			end

			local function norm(path)
				return (vim.fs.normalize(path):gsub("\\", "/"):lower())
			end

			local current_file = vim.api.nvim_buf_get_name(0)
			local uv = vim.uv or vim.loop
			local cwd = uv.cwd() or ""
			local current_dir = cwd
			if current_file ~= "" then
				current_dir = vim.fs.dirname(current_file)
			end
			local current_norm = norm(current_dir)

			local function score_target(target)
				local score = 0
				local target_norm = norm(target)
				local target_dir = norm(vim.fs.dirname(target))

				if target_norm:match("%.sln$") then
					score = score + 1000
				elseif target_norm:match("%.csproj$") then
					score = score + 500
				end

				if current_norm == target_dir then
					score = score + 400
				elseif vim.startswith(current_norm, target_dir .. "/") then
					score = score + 300
				elseif vim.startswith(target_dir, current_norm .. "/") then
					score = score + 150
				end

				-- Prefer deeper matching directories when multiple targets are valid.
				score = score + #target_dir

				return score
			end

			local best = targets[1]
			local best_score = -math.huge

			for _, target in ipairs(targets) do
				local score = score_target(target)

				if score > best_score then
					best = target
					best_score = score
				end
			end

			return best
		end,
	},
	config = function(_, opts)
		local setup = require("colin.lsp.lsp-setup")

		vim.lsp.config("roslyn", {
			capabilities = setup.capabilities_with_snippets,
			settings = {
				["csharp|background_analysis"] = {
					dotnet_compiler_diagnostics_scope = "fullSolution",
					dotnet_analyzer_diagnostics_scope = "openFiles",
				},
				["csharp|completion"] = {
					dotnet_show_completion_items_from_unimported_namespaces = true,
					dotnet_show_name_completion_suggestions = true,
					dotnet_provide_regex_completions = false,
				},
				["csharp|symbol_search"] = {
					dotnet_search_reference_assemblies = true,
				},
			},
		})

		local roslyn_attach_group = vim.api.nvim_create_augroup("UserRoslynAttach", { clear = true })
		vim.api.nvim_create_autocmd("LspAttach", {
			group = roslyn_attach_group,
			callback = function(args)
				if not args.data or not args.data.client_id then
					return
				end

				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client or client.name ~= "roslyn" then
					return
				end

				handle_roslyn_attach(client, args.buf)
			end,
		})

		require("roslyn").setup(opts)
	end,
}
