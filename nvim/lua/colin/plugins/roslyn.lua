return {
	"seblyng/roslyn.nvim",
	ft = { "cs", "razor", "cshtml" },
	dependencies = { "williamboman/mason-lspconfig.nvim" },
	---@module 'roslyn.config'
	---@type RoslynNvimConfig
	opts = {
		filewatching = "roslyn",
		broad_search = true,
		lock_target = true,
		choose_target = function(targets)
			if not targets or #targets == 0 then
				return nil
			end

			local function norm(path)
				return (vim.fs.normalize(path):gsub("\\", "/"):lower())
			end

			local current_file = vim.api.nvim_buf_get_name(0)
			local cwd = vim.uv.cwd() or ""
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
		local attach = require("colin.lsp.lsp-attach")

		vim.lsp.config("roslyn", {
			capabilities = setup.capabilities_with_snippets,
			on_attach = attach.on_attach,
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

		require("roslyn").setup(opts)
	end,
}
