local M = {}

local function inherit_vimrc()
	local ok, err = pcall(vim.cmd, [[ source ~/.vimrc ]])
	if not ok then
		vim.schedule(function()
			vim.notify("Failed to source ~/.vimrc: " .. err, vim.log.levels.WARN)
		end)
	end
end

local function opt_overrides()
	local options = {
		clipboard = "unnamed,unnamedplus",
		completeopt = "menuone,noselect",
		mouse = "a",
		termguicolors = true,
		signcolumn = "yes",
		background = "dark",
		conceallevel = 1,
	}
	for key, value in pairs(options) do
		vim.opt[key] = value
	end
	vim.g.have_nerd_font = true
	vim.g.netrw_browse_split = 0
	vim.g.netrw_banner = 1
	vim.g.netrw_winsize = 25
end

local function leader(key)
	vim.g.mapleader = key
	vim.g.maplocalleader = key
end

function M.setup(opts)
	if opts.inherit_vimrc then
		inherit_vimrc()
	end
	opt_overrides()
	leader(opts.leader)
end

return M
