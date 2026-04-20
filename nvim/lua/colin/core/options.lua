local M = {}

local function setup_wsl_clipboard()
	local uv = vim.uv or vim.loop
	local function exists(path)
		local ok, stat = pcall(uv.fs_stat, path)
		return ok and stat ~= nil
	end

	local function in_wsl()
		if vim.fn.has("wsl") == 1 or vim.env.WSL_DISTRO_NAME ~= nil or vim.env.WSL_INTEROP ~= nil then
			return true
		end

		local proc_version = io.open("/proc/version", "r")
		if not proc_version then
			return false
		end

		local content = proc_version:read("*a") or ""
		proc_version:close()
		content = content:lower()
		return content:find("microsoft", 1, true) ~= nil or content:find("wsl", 1, true) ~= nil
	end

	local is_wsl = vim.fn.has("wsl") == 1
		or vim.env.WSL_DISTRO_NAME ~= nil
		or vim.env.WSL_INTEROP ~= nil
		or vim.fn.executable("wsl.exe") == 1
		or vim.fn.executable("clip.exe") == 1
		or vim.fn.executable("powershell.exe") == 1
		or in_wsl()

	if not is_wsl then
		return
	end

	local clip_cmd = vim.fn.executable("clip.exe") == 1 and "clip.exe" or "/mnt/c/Windows/System32/clip.exe"
	local ps_cmd = vim.fn.executable("powershell.exe") == 1 and "powershell.exe"
		or "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

	local win32yank_cmd = vim.fn.executable("win32yank.exe") == 1 and "win32yank.exe"
		or "/mnt/c/Users/" .. (vim.env.USERNAME or "") .. "/scoop/shims/win32yank.exe"

	if win32yank_cmd ~= "" and (win32yank_cmd == "win32yank.exe" or exists(win32yank_cmd)) then
		vim.g.clipboard = {
			name = "win32yank-wsl",
			copy = {
				["+"] = { win32yank_cmd, "-i", "--crlf" },
				["*"] = { win32yank_cmd, "-i", "--crlf" },
			},
			paste = {
				["+"] = { win32yank_cmd, "-o", "--lf" },
				["*"] = { win32yank_cmd, "-o", "--lf" },
			},
			cache_enabled = 0,
		}
		return
	end

	-- Fallback for WSL without win32yank.
	if (clip_cmd == "clip.exe" or exists(clip_cmd)) and (ps_cmd == "powershell.exe" or exists(ps_cmd)) then
		vim.g.clipboard = {
			name = "wsl-clip",
			copy = {
				["+"] = { clip_cmd },
				["*"] = { clip_cmd },
			},
			paste = {
				["+"] = {
					ps_cmd,
					"-NoProfile",
					"-NoLogo",
					"-Command",
					"[Console]::Out.Write((Get-Clipboard -Raw).ToString())",
				},
				["*"] = {
					ps_cmd,
					"-NoProfile",
					"-NoLogo",
					"-Command",
					"[Console]::Out.Write((Get-Clipboard -Raw).ToString())",
				},
			},
			cache_enabled = 0,
		}
		return
	end

	vim.notify(
		"WSL detected but no Windows clipboard bridge executable found; Neovim may fall back to wl-copy/xclip.",
		vim.log.levels.WARN
	)
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
