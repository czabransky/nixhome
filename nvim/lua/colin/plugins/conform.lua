return {
	"stevearc/conform.nvim",
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "[C]ode [F]ormat",
		},
	},
	config = function()
		require("conform").setup({
			-- kulala-fmt (formatters_by_ft.http/rest below) inserts a blank
			-- line after every ###/# @name comment - not configurable, just
			-- its opinionated style. Excluded here so it doesn't rewrite
			-- .http files on every save; <leader>cf still runs it manually.
			format_on_save = function(bufnr)
				local ft = vim.bo[bufnr].filetype
				if ft == "http" or ft == "rest" then
					return
				end
				return {
					timeout_ms = 500,
					lsp_format = "fallback",
				}
			end,
			formatters_by_ft = {
				lua = { "stylua", lsp_format = "fallback" },
				python = { "isort", "black" },
				rust = { "rustfmt", lsp_format = "fallback" },
				nix = { "nixfmt" },
				http = { "kulala-fmt" },
				rest = { "kulala-fmt" },
				javascript = { "biome", "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
				typescript = { "biome", "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
			},
		})
	end,
}
