local M = {}

local function setup_wsl_clipboard()
	local is_wsl = vim.fn.has("wsl") == 1
		or vim.env.WSL_DISTRO_NAME ~= nil
		or vim.env.WSL_INTEROP ~= nil
		or vim.fn.executable("wsl.exe") == 1
		or vim.fn.executable("clip.exe") == 1
		or vim.fn.executable("powershell.exe") == 1

	if not is_wsl then
		return
	end

	if vim.fn.executable("win32yank.exe") == 1 then
		vim.g.clipboard = {
			name = "win32yank-wsl",
			copy = {
				["+"] = { "win32yank.exe", "-i", "--crlf" },
				["*"] = { "win32yank.exe", "-i", "--crlf" },
			},
			paste = {
				["+"] = { "win32yank.exe", "-o", "--lf" },
				["*"] = { "win32yank.exe", "-o", "--lf" },
			},
			cache_enabled = 0,
		}
		return
	end

	-- Fallback for WSL without win32yank.
	if vim.fn.executable("clip.exe") == 1 and vim.fn.executable("powershell.exe") == 1 then
		vim.g.clipboard = {
			name = "wsl-clip",
			copy = {
				["+"] = { "clip.exe" },
				["*"] = { "clip.exe" },
			},
			paste = {
				["+"] = {
					"powershell.exe",
					"-NoProfile",
					"-NoLogo",
					"-Command",
					"[Console]::Out.Write((Get-Clipboard -Raw).ToString())",
				},
				["*"] = {
					"powershell.exe",
					"-NoProfile",
					"-NoLogo",
					"-Command",
					"[Console]::Out.Write((Get-Clipboard -Raw).ToString())",
				},
			},
			cache_enabled = 0,
		}
	end
end

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
	setup_wsl_clipboard()
	leader(opts.leader)
end

return M
