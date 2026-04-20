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

			local cwd = vim.uv.cwd()
			local best = targets[1]
			local best_score = -math.huge

			for _, target in ipairs(targets) do
				local score = 0

				if target:match("%.sln$") then
					score = score + 100
				elseif target:match("%.csproj$") then
					score = score + 20
				end

				if cwd and vim.startswith(target, cwd) then
					score = score + 50
				end

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
