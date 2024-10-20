--- @param trunc_width number trunctates component when screen width is less then trunc_width
--- @param trunc_len number truncates component to trunc_len number of chars
--- @param hide_width number hides component when window width is smaller then hide_width
--- @param no_ellipsis boolean whether to disable adding '...' at end after truncation
--- return function that can format the component accordingly
local function trunc(trunc_width, trunc_len, hide_width, no_ellipsis)
	return function(str)
		local win_width = vim.fn.winwidth(0)
		if hide_width and win_width < hide_width then
			return ""
		elseif trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
			return str:sub(1, trunc_len) .. (no_ellipsis and "" or "...")
		end
		return str
	end
end

local function diff_source()
	local gitsigns = vim.b.gitsigns_status_dict
	if gitsigns then
		return {
			added = gitsigns.added,
			modified = gitsigns.changed,
			removed = gitsigns.removed,
		}
	end
end

local function getWords()
	if vim.bo.filetype == "md" or vim.bo.filetype == "txt" or vim.bo.filetype == "markdown" then
		if vim.fn.wordcount().visual_words == 1 then
			return tostring(vim.fn.wordcount().visual_words) .. " word"
		elseif not (vim.fn.wordcount().visual_words == nil) then
			return tostring(vim.fn.wordcount().visual_words) .. " words"
		else
			return tostring(vim.fn.wordcount().words) .. " words"
		end
	else
		return ""
	end
end

-- adapted from https://www.reddit.com/r/neovim/comments/xy0tu1/cmdheight0_recording_macros_message/
local function show_macro_recording()
	local recording_register = vim.fn.reg_recording()
	if recording_register == "" then
		return ""
	else
		return "󰑋  " .. recording_register
	end
end


return {
	'nvim-lualine/lualine.nvim',
	config = function()
		local lazy_status = require('lazy.status')
		require('lualine').setup {
			options = {
				theme = 'auto',
				icons_enabled = true,
				component_separators = ' ',
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = {
					{ "mode", fmt = trunc(80, 1, nil, true) },
				},
				lualine_b = {
					{ "branch", icon = "󰘬" },
					{
						"diff",
						colored = true,
						source = diff_source,
						diff_color = {
							color_added = "#a7c080",
							color_modified = "#ffdf1b",
							color_removed = "#ff6666",
						},
					},
				},
				lualine_c = {
					{ "diagnostics",    sources = { "nvim_diagnostic" } }, function() return "%=" end,
					{
						"filename",
						file_status = true,
						path = 0,
						shorting_target = 40,
						symbols = {
							modified = "󰐖", -- Text to show when the file is modified.
							readonly = "", -- Text to show when the file is non-modifiable or readonly.
							unnamed = "[No Name]", -- Text to show for unnamed buffers.
							newfile = "[New]", -- Text to show for new created file before first writting
						},
					},
					{
						getWords,
						color = { fg = "#333333", bg = "#eeeeee" },
						separator = { left = "", right = "" },
					},
					{ "searchcount", },
					{ "selectioncount", },
					{
						show_macro_recording,
						color = { fg = "#333333", bg = "#ff6666" },
						separator = { left = "", right = "" },
					},
				},
				lualine_x = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = '#ff9e64' },
					},
					{ "filetype", icon_only = true } },
				-- luadine_y = {},
				-- lualine_z = {},
			},
		}

		local lualine = require("lualine")
		vim.api.nvim_create_autocmd("RecordingEnter", {
			callback = function()
				lualine.refresh()
			end,
		})

		vim.api.nvim_create_autocmd("RecordingLeave", {
			callback = function()
				-- This is going to seem really weird!
				-- Instead of just calling refresh we need to wait a moment because of the nature of
				-- `vim.fn.reg_recording`. If we tell lualine to refresh right now it actually will
				-- still show a recording occuring because `vim.fn.reg_recording` hasn't emptied yet.
				-- So what we need to do is wait a tiny amount of time (in this instance 50 ms) to
				-- ensure `vim.fn.reg_recording` is purged before asking lualine to refresh.
				local timer = vim.loop.new_timer()
				timer:start(
					50,
					0,
					vim.schedule_wrap(function()
						lualine.refresh()
					end)
				)
			end,
		})
	end,
}
