local M = {}

-- Curated list of colorscheme names to offer in the picker (see M.picker).
-- Keep in sync with the flavour/variant each theme function below activates.
M.list = {
	"catppuccin-frappe",
	"everforest",
	"gruvbox",
	"kanagawa-wave",
	"onedark",
	"tokyonight-night",
}

M.default = "onedark"

local state_file = vim.fn.stdpath("state") .. "/theme"

function M.save(name)
	local f = io.open(state_file, "w")
	if not f then return end
	f:write(name)
	f:close()
end

function M.load()
	local f = io.open(state_file, "r")
	if not f then return nil end
	local name = f:read("*l")
	f:close()
	return name ~= "" and name or nil
end

-- Call once at startup (after plugins load) to (re)apply whichever theme was
-- last selected via M.picker, falling back to M.default if nothing is saved
-- or the saved theme is no longer available.
function M.apply_saved()
	if not pcall(vim.cmd.colorscheme, M.load() or M.default) then
		vim.cmd.colorscheme(M.default)
	end
end

-- Persist any colorscheme change, whether it came from the picker below or a
-- plain `:colorscheme ...`, so the next startup picks it back up.
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("UserThemePersist", { clear = true }),
	callback = function(ev)
		M.save(ev.match)
	end,
})

-- Some colorschemes (onedark.nvim, catppuccin, gruvbox) never define
-- @lsp.type.class/struct, so LSP-semantic-token class/struct references
-- (e.g. a static class qualifier like `AdminBootstrapper.Foo()`) render as
-- plain text instead of getting colored - others (tokyonight, kanagawa,
-- everforest) already handle it fine. Rather than patching each theme by
-- hand, backfill only the groups a given colorscheme left undefined, right
-- after it (re)loads - `:colorscheme` fully resets highlights first, so
-- this must run on ColorScheme, not just once at startup.
local function fill_missing_hl(name, fallback)
	if next(vim.api.nvim_get_hl(0, { name = name, link = false })) == nil then
		vim.api.nvim_set_hl(0, name, { link = fallback })
	end
end

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("UserLspSemanticFallbacks", { clear = true }),
	callback = function()
		fill_missing_hl("@lsp.type.class", "@type")
		fill_missing_hl("@lsp.type.struct", "@type")
	end,
})

-- Telescope picker over M.list, with live preview as you move the selection
-- (reverts on <Esc>) via telescope's builtin colorscheme picker.
function M.picker()
	require("telescope.builtin").colorscheme({
		prompt_title = "Themes",
		colors = M.list,
		enable_preview = true,
		ignore_builtins = true,
	})
end

function M.catppuccin()
	return {
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "frappe",
			})
		end,
	}
end

function M.everforest()
	return {
		"neanias/everforest-nvim",
		version = false,
		lazy = false,
		priority = 1000,
		config = function()
			vim.g.everforest_terminal_colors = 1
			vim.g.everforest_background = "medium"
			vim.g.everforest_enable_italic = 1
			vim.g.everforest_better_performance = 1
			vim.g.everforest_cursor = "aqua"
		end,
	}
end

function M.gruvbox()
	return {
		"morhetz/gruvbox",
		lazy = false,
		priority = 1000,
	}
end

function M.kanagawa()
	return {
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
	}
end

function M.onedark()
	return {
		"navarasu/onedark.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("onedark").setup({
				style = "dark",
				toggle_style_key = "<leader>ts",
			})
		end,
	}
end

function M.tokyonight()
	return {
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	}
end

return M
