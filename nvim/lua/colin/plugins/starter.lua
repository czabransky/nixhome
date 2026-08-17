-- mini.starter (part of mini.nvim, configured in plugins/mini.lua). Like
-- plugins/tree.lua, this exposes named alternatives; whichever one is called
-- from mini.lua's config is the active splash behavior.
local M = {}

-- No splash screen; mini.starter is simply never set up.
function M.none() end

local ascii_art = table.concat({
	"                                               ░▄                 ",
	"                                              ▄█░                 ",
	" ▄▄▄ ▄▄▄       ▄▄▄▄▄      ▄▄▄▄     ▄▄▄  ▄▄▄▄ ▐▒▓▌ ▄▄▄ ▄▄▄   ▄▄    ",
	" ▐░░░░░░░▄   ▄▒▒▒▒▒▒▒▄  ▄▒▒▒▒▒▒▄  ▐░▒▒ ▐▒▒▒▓  ▀░  ▐░░░░░░░▄░░░░▄  ",
	" ▐▒▒▒▀░░▒▒▒ ▐▒▒▒▀▐▒▒▒▓ ▐▒▒▒▀▐▒▒▒▌ ▐▒▒▒ ▐▒▒▒▓  ▄▄▄ ▐▒▒▒▀░░▒▒▀░░▒▒▒ ",
	" ▐▓▓▒ ▐▒▒▓▓ ▐▓▓▓ ▐▓▓▓▓ ▐▓▓▓ ▐▓▓▓█ ▐▓▓▓ ▐▓▓▓█ ▐▒▒▒ ▐▓▓▒ ▐▒▒▓ ▐▒▒▓▓ ",
	" ▐██▓ ▐▓▓██ ▐███ ▐██▀▀ ▐███ ▐████ ▐███ ▐████ ▐▓▓▒ ▐██▓ ▐▓▓█ ▐▓▓██ ",
	" ▐███ ▐████ ▐███▄▀▀▀   ▐███ ▐████ ▐███ ▐████ ▐██▓ ▐███ ▐███ ▐████ ",
	" ▐▓▓█ ▐█▓▓▓ ▐▓▓▓  ▄▄▄▄ ▐▓▓▓ ▐▓▓██ ▐▓▓▓ ▐▓▓██ ▐███ ▐▓▓█ ▐█▓▓ ▐█▓▓▓ ",
	" ▐▒▓▓ ▐▓▓▒▒ ▐▒▒▒  ▒▓▓▓ ▐▒▒▒ ▐▒▓▓▓ ▐▒▒▒ ▐▒▓▓▌ ▐███ ▐▒▓▓ ▐▓▓▒ ▐▓▓▒▒ ",
	" ▐▒▒▒ ▐▒▒▒░ ▐░░░▄▓▒▒▒▌ ▐░░░▄█▒▒▒▌  ▐░░▄█▒▒▌  ▐▓▓▓ ▐▒▒▒      ▐▒▒▒░ ",
	" ▐░░░ ▐░░░░  ▀▓█░░░▓▀   ▀▓█░░░▓▀    ▀▀░░▀▀   ▐▒▒▒ ▐░░░      ▐░░░░ ",
}, "\n")

-- Icon per item, keyed by item.name. Query-matching uses item.name itself
-- (untouched), so this is purely cosmetic.
-- Nerd Font (Font Awesome subset) glyphs via \u{} escapes rather than literal
-- characters - literal PUA glyphs didn't survive being written to this file.
local ICONS = {
	["Find File"] = "\u{f002}",   -- search
	["Live Grep"] = "\u{f002}",   -- search
	["Recent Files"] = "\u{f016}", -- file-o
	["Explorer"] = "\u{f07c}",    -- folder-open
	["New File"] = "\u{f016}",    -- file-o
	["Configuration"] = "\u{f013}", -- cog
	["Update Plugins"] = "\u{f021}", -- refresh
	["Session"] = "\u{f1da}",     -- history
	["Quit"] = "\u{f011}",        -- power-off
}

-- Adds an icon unit before, and a right-aligned shortcut-letter unit after,
-- each item's own unit - WITHOUT touching that unit's string, since
-- content_to_items() reads the item's matching name straight from it
-- (mutating it here would break the evaluate_single single-key shortcuts).
-- Mirrors the insertion pattern used by mini.starter's own gen_hook.adding_bullet.
-- Then inserts blank lines between items.
local function layout(gap)
	return function(content, _)
		local coords = require("mini.starter").content_coords(content, "item")

		local left_width = 0
		for _, c in ipairs(coords) do
			local item = content[c.line][c.unit].item
			local icon = ICONS[item.name] or " "
			left_width = math.max(left_width, vim.fn.strdisplaywidth(icon .. "  " .. item.name))
		end

		for i = #coords, 1, -1 do
			local l_num, u_num = coords[i].line, coords[i].unit
			local item = content[l_num][u_num].item
			local icon = ICONS[item.name] or " "
			local pad = string.rep(" ", left_width - vim.fn.strdisplaywidth(icon .. "  " .. item.name) + 4)

			table.insert(content[l_num], u_num + 1, {
				string = pad .. item.name:sub(1, 1):upper(),
				type = "item_prefix",
				hl = "MiniStarterItemPrefix",
			})
			table.insert(content[l_num], u_num, {
				string = icon .. "  ",
				type = "item_icon",
				hl = "MiniStarterItem",
			})
		end

		-- Insert blank spacer lines between items (reverse order so earlier
		-- inserts don't shift the line numbers still to be processed).
		local item_lines = {}
		for _, c in ipairs(coords) do
			item_lines[c.line] = true
		end
		local sorted = {}
		for l in pairs(item_lines) do
			table.insert(sorted, l)
		end
		table.sort(sorted)
		for i = #sorted, 2, -1 do
			for _ = 1, gap do
				table.insert(content, sorted[i], {})
			end
		end

		return content
	end
end

-- gen_hook.aligning('center', ...) centers the whole block by giving every
-- line the SAME left-pad, sized off the single widest line (the header) - so
-- narrower lines (the item rows) just inherit the header's left edge instead
-- of being centered on their own. This centers item/footer/subtitle lines
-- independently - but header lines share ONE pad (computed from the widest
-- header line), since ascii art relies on its lines staying aligned to each
-- other (e.g. a dotted-i's dot has to stay above its letter, not float to
-- the window's center on its own).
local function center_each_line()
	return function(content, buf_id)
		local win_id = vim.fn.bufwinid(buf_id)
		if win_id < 0 then
			return content
		end
		local win_width = vim.api.nvim_win_get_width(win_id)

		local header_width = 0
		for _, line in ipairs(content) do
			for _, unit in ipairs(line) do
				if unit.type == "header" then
					header_width = math.max(header_width, vim.fn.strdisplaywidth(unit.string))
				end
			end
		end
		local header_pad = math.max(math.floor((win_width - header_width) / 2), 0)

		for _, line in ipairs(content) do
			local is_empty_line = #line == 0 or (#line == 1 and line[1].string == "")
			local is_header_line = line[1] ~= nil and line[1].type == "header"
			if not is_empty_line then
				local pad
				if is_header_line then
					pad = header_pad
				else
					local text = table.concat(vim.tbl_map(function(u)
						return u.string
					end, line))
					pad = math.max(math.floor((win_width - vim.fn.strdisplaywidth(text)) / 2), 0)
				end
				table.insert(line, 1, { string = string.rep(" ", pad), type = "empty", hl = nil })
			end
		end

		return content
	end
end

function M.splash()
	local starter = require("mini.starter")

	starter.setup({
		-- cwd deliberately isn't concatenated in here: header lines share one
		-- pad so the art's internal alignment holds together (a dotted-i's dot
		-- has to stay above its letter), but that means anything else appended
		-- to header would inherit the art's left edge instead of being
		-- centered as its own short caption - so cwd lives in the footer.
		header = ascii_art,
		-- Every item name starts with a different letter, so with
		-- evaluate_single = true one keypress (no <CR>) runs the action.
		items = {
			{
				name = "Session",
				action = function()
					require("persistence").load()
				end,
				section = "",
			},
			{ name = "Find File",      action = "Telescope find_files",         section = "" },
			{ name = "Live Grep",      action = "Telescope live_grep",          section = "" },
			{ name = "Recent Files",   action = "Telescope oldfiles",           section = "" },
			{ name = "Explorer",       action = "NvimTreeToggle",               section = "" },
			{ name = "New File",       action = "enew",                         section = "" },
			{ name = "Configuration",  action = "edit ~/nixhome/nvim/init.lua", section = "" },
			{ name = "Update Plugins", action = "Lazy sync",                    section = "" },
			{ name = "Quit",           action = "qa",                           section = "" },
		},
		content_hooks = {
			layout(1),
			center_each_line(),
			-- horizontal = 'left' so this only contributes vertical centering;
			-- horizontal centering is handled per-line above.
			starter.gen_hook.aligning("left", "center"),
		},
		evaluate_single = true,
		footer = function()
			local stats = require("lazy").stats()
			return table.concat({
				vim.fn.getcwd(),
				"",
				string.format("%d/%d plugins loaded in %.1fms", stats.loaded, stats.count, stats.startuptime),
			}, "\n")
		end,
	})
end

return M
