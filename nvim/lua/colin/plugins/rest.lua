-- https://github.com/rest-nvim/rest.nvim
-- HTTP client for .http files (JetBrains .http spec), replacing kulala.nvim
-- (see plugins/archive/kulala.lua) which wasn't working reliably. No .setup()
-- call - it's configured entirely through the vim.g.rest_nvim table, read
-- when a .http buffer first loads the plugin.
--
-- Needs the tree-sitter "http" parser (ensure_installed in
-- plugins/treesitter.lua) - rest.nvim parses requests via treesitter, not a
-- custom lexer.
--
-- luarocks disabled repo-wide (lazy.lua's rocks.enabled = false): lazy.nvim
-- auto-detects rest.nvim's rockspec and tries to install its deps via
-- luarocks, but the tree-sitter-http rock's build backend
-- (luarocks-build-treesitter-parser) is broken against lazy.nvim's bundled
-- Lua 5.1 - still open upstream as
-- https://github.com/rest-nvim/rest.nvim/issues/559 (plugin-level `build =
-- false` alone does NOT suppress it - the rockspec-detected fragment's
-- build = "rockspec" wins the merge regardless). The tree-sitter parser
-- itself already comes from nvim-treesitter above, so the rock is redundant
-- anyway; the other three (fidget.nvim, nvim-nio, xml2lua, mimetypes) are
-- real runtime deps (see autocmds.lua/libcurl.lua/parser/init.lua upstream),
-- so they're listed as plain dependencies instead. xml2lua/lua-mimetypes
-- have no lua/ subdir, so Neovim's loader won't find them on its own -
-- each needs its repo root added to package.path by hand.
--
-- rest.nvim's own result pane never shows the REQUEST's resolved headers/
-- body (ui/result.lua's render_request() only emits "### name" + "METHOD
-- url" - its "Headers" pane is response-only), so there's no built-in way
-- to see e.g. whether {{adminAccessToken}} actually substituted into the
-- Authorization header. inspect() below re-parses the request under the
-- cursor the same way M.run() does (parser.parse against a fresh Context,
-- wrapped in nio.run since prompt-variable requests need that coroutine
-- context) but without calling run_request(), so nothing is sent - then
-- shows the fully-resolved method/url/headers/body in a floating window,
-- closer to kulala's <leader>Ri inspect popup than a single-var notify.
---formatexpr for filetype=json, called by `gq` (see the FileType autocmd in
---config() below). A *formatprg* was tried first (simpler), but formatprg's
---mechanism for `gq` is running `:{range}!{formatprg}` as a literal ex
---command (see :help formatprg) - visible proof from a screen recording of
---<leader>Ra: a noice.nvim "Cmdline" popup flashing `.!jq .` on every
---response, one per request. formatexpr instead calls this Lua function
---directly - vim.fn.system() here is a plain blocking subprocess call, never
---touching the cmdline/ex-command machinery, so there's nothing for a
---cmdline UI to show.
_G.rest_nvim_json_formatexpr = function()
	local first, count = vim.v.lnum, vim.v.count
	local lines = vim.api.nvim_buf_get_lines(0, first - 1, first - 1 + count, false)
	local out = vim.fn.system({ "jq", "." }, table.concat(lines, "\n"))
	if vim.v.shell_error ~= 0 then
		return 1 -- non-zero: fall back to Vim's internal formatting
	end
	vim.api.nvim_buf_set_lines(0, first - 1, first - 1 + count, false, vim.split(out, "\n", { trimempty = true }))
	return 0
end

---Close every visible window whose buffer filetype starts with "rest_nvim"
---(the built-in Response/Headers/Cookies/Statistics panes and our own
---Report pane all share that prefix). Returns whether anything was closed,
---so callers can use it as the "close" half of an open/close toggle.
---@return boolean closed_any
local function close_rest_windows()
	local closed_any = false
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype:match("^rest_nvim") then
			closed_any = pcall(vim.api.nvim_win_close, win, true) or closed_any
		end
	end
	return closed_any
end

-- <leader>Ro toggle: rest.nvim's own `open` command (rest-nvim/commands.lua)
-- only splits when given command modifiers (`:vert Rest open`) - plain
-- `:Rest open`, which is what a keymap sends, calls split_open_cmd() with no
-- smods, which skips the split entirely and just takes over the CURRENT
-- window. (The `open_result_ui` local function in that same file DOES
-- default to a vertical split, but it's dead code - the `open` subcommand's
-- impl calls split_open_cmd() directly, never open_result_ui().) This forces
-- an explicit vsplit every time instead of depending on modifiers, and
-- closes every rest_nvim* window (all panes, including Report) on a second
-- press rather than the no-op `:Rest open` does when a pane's already open.
local function toggle_result()
	if close_rest_windows() then
		return
	end
	vim.cmd("vsplit")
	local winid = vim.api.nvim_get_current_win()
	require("rest-nvim.ui.result").enter(winid)
	vim.cmd.wincmd("p")
end

local function inspect()
	local parser = require("rest-nvim.parser")
	local Context = require("rest-nvim.context").Context
	local config = require("rest-nvim.config")

	local req_node = parser.get_request_node()
	if not req_node then
		vim.notify("No request under cursor", vim.log.levels.WARN, { title = "rest.nvim" })
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	require("nio").run(function()
		local ctx = Context:new()
		if config.env.enable and vim.b[bufnr]._rest_nvim_env_file then
			ctx:load_file(vim.b[bufnr]._rest_nvim_env_file)
		end
		local ok, req = pcall(parser.parse, req_node, bufnr, ctx)

		vim.schedule(function()
			if not ok or not req then
				vim.notify("Failed to resolve request under cursor", vim.log.levels.ERROR, { title = "rest.nvim" })
				return
			end

			local lines = { ("%s %s"):format(req.method, req.url) }
			for name, values in pairs(req.headers) do
				for _, value in ipairs(values) do
					table.insert(lines, ("%s: %s"):format(name, value))
				end
			end
			if req.body and req.body.data then
				table.insert(lines, "")
				local data = req.body.data
				vim.list_extend(lines, vim.split(type(data) == "string" and data or vim.inspect(data), "\n"))
			end

			local width = 20
			for _, line in ipairs(lines) do
				width = math.max(width, vim.fn.strdisplaywidth(line))
			end
			width = math.min(width + 2, math.floor(vim.o.columns * 0.8))
			local height = math.min(#lines, math.floor(vim.o.lines * 0.6))

			local buf = vim.api.nvim_create_buf(false, true)
			vim.bo[buf].filetype = "http"
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
			vim.bo[buf].modifiable = false

			local win = vim.api.nvim_open_win(buf, true, {
				relative = "cursor",
				row = 1,
				col = 0,
				width = width,
				height = height,
				border = "rounded",
				style = "minimal",
				title = " Resolved Request ",
			})
			vim.wo[win].wrap = false
			for _, lhs in ipairs({ "q", "<esc>" }) do
				vim.keymap.set("n", lhs, "<cmd>close<cr>", { buffer = buf, nowait = true, silent = true })
			end
		end)
	end)
end

-- rest.nvim has no run-all: request.lua's M.run() only ever resolves and
-- fires ONE request node, and the function that actually sends it
-- (run_request - client dispatch, response handlers, cookie jar, UI update)
-- is a local, non-exported upstream, so it can't be called directly here.
-- This reimplements that same sequence (matching run_request line for line:
-- client dispatch -> response handlers -> cookie jar -> UI update) in a loop
-- over every request node in the buffer, top to bottom. Doing it inside ONE
-- nio coroutine matters: client.request(req).wait actually blocks that
-- coroutine until the response arrives, so each iteration only starts once
-- the previous one is fully done - required for chains like
-- adminLogin -> createInvite -> redeemInvite, where a later request's
-- {{adminAccessToken}} depends on the earlier one's post-request script
-- having already run (client.global.set is vim.env under the hood - see
-- inspect() above). Looping plain M.run(name) calls instead would race,
-- since each spawns its own independent coroutine.
-- Report: run_all() below appends one entry per request here; open_report()
-- renders it. rest.nvim's script API has no assertion/test framework like
-- kulala's client.test/assert.* (see kulala's own
-- doc/kulala.testing-and-reporting.txt) - there's nothing here to assert
-- against, so PASS/FAIL is purely HTTP-status-based (2xx/3xx passes,
-- anything else - 4xx/5xx or the request erroring out entirely - fails).
---@type {name:string, method:string, ok:boolean, detail:string, bufnr:integer, line:integer}[]
local report_entries = {}

-- report_entries is shared, mutable module state, and run_nodes() below
-- reassigns it wholesale (report_entries = {}) at the start of every run -
-- two overlapping runs (e.g. <leader>Ra fired again before a prior chain
-- over a real, slower API finished) race on that reassignment and on the
-- table.insert()s that follow, corrupting whichever run's table survives.
-- Confirmed directly: firing a second run_all() ~150ms into a first one
-- produced a report stuck on a wrong, truncated count that didn't correct
-- itself even on a subsequent clean run - because that clean run's inserts
-- were themselves landing in a table an unfinished earlier coroutine could
-- still reassign out from under it. run_in_progress makes overlap
-- impossible instead of trying to make it safe.
local run_in_progress = false

-- A literal tab on the built-in "rest_nvim_result" pane group (cycling via
-- the existing H/L keys alongside Response/Headers/Cookies/Statistics) - not
-- by reaching into that group's state after the fact (ui/panes.lua's
-- create_pane_group() errors on a name that's already registered, and the
-- module-level table it lives in has no public getter), but by wrapping the
-- PUBLIC create_pane_group() function itself: when ui/result.lua calls it
-- with name == "rest_nvim_result", we splice our own pane spec into the
-- *pane_opts list it was given* before forwarding to the real,
-- unmodified create_pane_group(). The real function still does 100% of the
-- actual construction (buffer creation, on_init wiring, modifiable
-- toggling) for our pane too - we're not duplicating any of its private
-- logic, just injecting one more entry into a list it already iterates.
-- Must run before rest-nvim.ui.result is required for the first time by
-- anyone (verified: none of rest.nvim's eagerly-loaded files - plugin/
-- rest-nvim.lua, autocmds.lua, commands.lua's .setup() - touch it; every
-- ui() access in commands.lua is a lazy `require()` inside a command's
-- impl), so this is called once at the very top of config() below.
local result_group ---@type rest.ui.panes.PaneGroup?

---Right-pad `s` to `width` display columns (not bytes - strdisplaywidth,
---not #s, since names can carry multi-byte UTF-8 like the em-dash in
---"### Basic liveness check — no auth required.").
local function pad_display(s, width)
	local w = vim.fn.strdisplaywidth(s)
	return w >= width and s or (s .. string.rep(" ", width - w))
end

---Truncate `s` to at most `width` display columns, trimming by character
---(strcharpart) rather than byte so multi-byte UTF-8 never gets split
---mid-character, with a trailing ellipsis if it was actually cut.
local function truncate_display(s, width)
	if vim.fn.strdisplaywidth(s) <= width then
		return s
	end
	local out = s
	while vim.fn.strdisplaywidth(out) > width - 1 and vim.fn.strchars(out) > 0 do
		out = vim.fn.strcharpart(out, 0, vim.fn.strchars(out) - 1)
	end
	return out .. "…"
end

local function ensure_report_hl()
	for name, source in pairs({ RestReportOk = "DiagnosticOk", RestReportError = "DiagnosticError" }) do
		local src = vim.api.nvim_get_hl(0, { name = source, link = false })
		vim.api.nvim_set_hl(0, name, vim.tbl_extend("force", src, { bold = true }))
	end
end

local function install_report_tab()
	ensure_report_hl()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("RestNvimReportHl", { clear = true }),
		callback = ensure_report_hl,
	})

	local paneui = require("rest-nvim.ui.panes")
	local ns = vim.api.nvim_create_namespace("rest_nvim_report")
	local original_create_pane_group = paneui.create_pane_group

	paneui.create_pane_group = function(name, pane_opts, opts)
		if name == "rest_nvim_result" then
			table.insert(pane_opts, {
				name = "Report",
				-- Group-level on_init (set in ui/result.lua) already gives
				-- this pane the H/L cycle keys, "?" help, and filetype -
				-- only the jump-to-source behavior is ours to add.
				on_init = function(self)
					vim.keymap.set("n", "<cr>", function()
						local entry = report_entries[vim.api.nvim_win_get_cursor(0)[1]]
						if not entry then
							return
						end
						vim.cmd.wincmd("p")
						vim.api.nvim_set_current_buf(entry.bufnr)
						vim.api.nvim_win_set_cursor(0, { entry.line, 0 })
					end, { buffer = self.bufnr, nowait = true, desc = "Jump to request" })

					-- render() below sizes columns off vim.fn.bufwinid(self.
					-- bufnr) - but the very first render (triggered by
					-- run_all()'s ui.update() calls, mid-loop) happens
					-- before this buffer is showing in any window at all,
					-- so that lookup falls back to a guess that's often
					-- wrong once the buffer actually lands in a real split
					-- (that mismatch is exactly what pushed the status
					-- column off the right edge). Re-render every time this
					-- buffer actually becomes visible - via H/L cycling,
					-- open_report(), or anything else - so column widths
					-- are always computed against the window really showing
					-- them.
					vim.api.nvim_create_autocmd("BufWinEnter", {
						buffer = self.bufnr,
						callback = function()
							self:render()
						end,
					})
				end,
				render = function(self)
					vim.api.nvim_buf_clear_namespace(self.bufnr, ns, 0, -1)
					if #report_entries == 0 then
						vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {
							"No run_all() results yet.",
							"<leader>Ra to run every request in a .http buffer.",
						})
						return false
					end

					-- Column widths are sized off the actual pane window and
					-- actual content, not fixed guesses - a hardcoded
					-- %-30.30s both wasted most of a wide split and (since
					-- Lua string patterns count bytes, not display cells)
					-- chopped multi-byte names like the em-dash above
					-- mid-character.
					--
					-- nvim_win_get_width() is the FULL window width,
					-- including the number/sign/fold column gutters (the
					-- line-number column visible on the left of this pane)
					-- - not the usable text width, so sizing off it
					-- directly overshoots by exactly the gutter width and
					-- clips the status column. getwininfo().textoff is the
					-- actual gutter width for THIS window, whatever its
					-- number/signcolumn/foldcolumn settings are - subtract
					-- it instead of a guessed constant.
					local win = vim.fn.bufwinid(self.bufnr)
					local width
					if win ~= -1 then
						local info = vim.fn.getwininfo(win)[1]
						width = vim.api.nvim_win_get_width(win) - (info and info.textoff or 0)
					else
						width = math.floor(vim.o.columns / 2)
					end

					local method_width, detail_width = 4, 0
					for _, entry in ipairs(report_entries) do
						method_width = math.max(method_width, vim.fn.strdisplaywidth(entry.method))
						detail_width = math.max(detail_width, vim.fn.strdisplaywidth(entry.detail))
					end
					local tag_width = 6 -- "[PASS]" / "[FAIL]"
					local separators = 3 -- one space each between tag/method/name/detail
					-- Floor of 1, not some larger "reasonable minimum" - a
					-- bigger floor guarantees overflow (and the status
					-- column clipping off the right edge, same visible
					-- symptom as the stale-width bug below) the moment the
					-- window is too narrow for tag+method+detail+that
					-- minimum to fit. Letting the name column shrink all
					-- the way down is the only way this stays truthful to
					-- the window's actual width at any size.
					local name_width = math.max(1, width - tag_width - method_width - detail_width - separators)

					local lines = {}
					local passed = 0
					for _, entry in ipairs(report_entries) do
						if entry.ok then
							passed = passed + 1
						end
						table.insert(
							lines,
							("[%s] %s %s %s"):format(
								entry.ok and "PASS" or "FAIL",
								pad_display(entry.method, method_width),
								pad_display(truncate_display(entry.name, name_width), name_width),
								entry.detail
							)
						)
					end
					table.insert(lines, "")
					table.insert(lines, ("%d/%d passed"):format(passed, #report_entries))
					vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)

					for i, entry in ipairs(report_entries) do
						local row = i - 1
						pcall(vim.api.nvim_buf_set_extmark, self.bufnr, ns, row, 1, {
							end_col = 5,
							hl_group = entry.ok and "RestReportOk" or "RestReportError",
						})
					end
					return false
				end,
			})
		end

		local group = original_create_pane_group(name, pane_opts, opts)
		if name == "rest_nvim_result" then
			result_group = group
		end
		return group
	end

	-- BufWinEnter (registered per-pane in on_init above) only re-renders
	-- when the Report buffer becomes newly visible in a window - it does
	-- NOT fire for a window that's already showing it and just gets
	-- resized wider/narrower in place (e.g. <leader>w.), so that case was
	-- still rendering against a stale width and clipping the status column.
	-- WinResized fires for exactly that case; re-render the Report pane
	-- specifically if one of the resized windows is showing it.
	vim.api.nvim_create_autocmd("WinResized", {
		group = vim.api.nvim_create_augroup("RestNvimReportResize", { clear = true }),
		callback = function()
			if not result_group then
				return
			end
			for _, winid in ipairs(vim.v.event.windows) do
				if vim.b[vim.api.nvim_win_get_buf(winid)].__pane_group == "rest_nvim_result" then
					for _, pane in ipairs(result_group.panes) do
						if pane.name == "Report" then
							pane:render()
							break
						end
					end
					break
				end
			end
		end,
	})
end

---Find the window (if any, in the current tabpage) currently showing a pane
---from the built-in result group - same technique ui/result.lua's own
---ui.is_open() uses (__pane_group buffer var), just without needing that
---module's private `group` local.
local function find_result_window()
	return vim.iter(vim.api.nvim_tabpage_list_wins(0)):find(function(win)
		return vim.b[vim.api.nvim_win_get_buf(win)].__pane_group == "rest_nvim_result"
	end)
end

---Open the result pane (if needed) and switch straight to its Report tab.
local function open_report()
	local winid = find_result_window()
	if not winid then
		vim.cmd("vsplit")
		winid = vim.api.nvim_get_current_win()
		require("rest-nvim.ui.result").enter(winid) -- builds result_group on first call
	end
	if not result_group then
		return
	end
	for _, pane in ipairs(result_group.panes) do
		if pane.name == "Report" then
			vim.api.nvim_win_set_buf(winid, pane.bufnr)
			-- Explicit, unconditional render - NOT relying on the
			-- BufWinEnter re-render from on_init above. BufWinEnter only
			-- fires when the buffer is newly entering this window; on the
			-- second and later run_all() in a session, this window
			-- already shows this exact buffer from the previous run, so
			-- nvim_win_set_buf above is a no-op that buffer's window
			-- attachment never re-fires BufWinEnter for. Without this,
			-- whatever render happened to run last (mid-loop, via
			-- ui.update()) is what stays on screen indefinitely.
			pane:render()
			break
		end
	end
	-- Always focus winid explicitly, not just as a side effect of the
	-- vsplit branch above - when the result window already exists (e.g.
	-- called again after run_nodes' auto-open already created it),
	-- nvim_win_set_buf alone changes what that window shows without moving
	-- focus there, so <leader>RR would silently stop "jumping" to it.
	-- run_nodes' auto-open call wraps this whole function with its own
	-- save/restore of the previous window, so this doesn't fight that.
	vim.api.nvim_set_current_win(winid)
end

---Shared by run_all() and run_to_cursor() - both just differ in which
---subset of the buffer's request nodes they pass in here.
---@param bufnr integer
---@param nodes TSNode[]
local function run_nodes(bufnr, nodes)
	if run_in_progress then
		vim.notify("A run is already in progress - wait for it to finish first", vim.log.levels.WARN, { title = "rest.nvim" })
		return
	end
	run_in_progress = true

	local parser = require("rest-nvim.parser")
	local Context = require("rest-nvim.context").Context
	local config = require("rest-nvim.config")
	local clients = require("rest-nvim.client")
	local jar = require("rest-nvim.cookie_jar")
	local ui = require("rest-nvim.ui.result")

	report_entries = {}

	require("nio").run(function()
		-- Wrapped in pcall so run_in_progress always gets released below,
		-- even on a genuinely unexpected error outside the pcall'd steps
		-- already inside the loop - otherwise a stuck-true lock would brick
		-- every run_all()/run_to_cursor() for the rest of the session.
		local run_ok, run_err = pcall(function()
			local ctx = Context:new()
			if config.env.enable and vim.b[bufnr]._rest_nvim_env_file then
				ctx:load_file(vim.b[bufnr]._rest_nvim_env_file)
			end

			for i, req_node in ipairs(nodes) do
				local start_row = req_node:range()
				local ok, req = pcall(parser.parse, req_node, bufnr, ctx)
				if not ok or not req then
					table.insert(report_entries, {
						name = ("#%d"):format(i),
						method = "?",
						ok = false,
						detail = "failed to parse request",
						bufnr = bufnr,
						line = start_row + 1,
					})
					break
				end

				local client = clients.get_available_clients(req)[1]
				if not client then
					table.insert(report_entries, {
						name = req.name or ("#" .. i),
						method = req.method,
						ok = false,
						detail = "no client available",
						bufnr = bufnr,
						line = start_row + 1,
					})
					break
				end

				ui.update({ request = req })
				local started = vim.uv.hrtime()
				local req_ok, res = pcall(client.request(req).wait)
				local elapsed_ms = math.floor((vim.uv.hrtime() - started) / 1e6)

				if not req_ok then
					table.insert(report_entries, {
						name = req.name or ("#" .. i),
						method = req.method,
						ok = false,
						detail = ("ERROR (%dms): %s"):format(elapsed_ms, res),
						bufnr = bufnr,
						line = start_row + 1,
					})
					break
				end

				vim.iter(req.handlers):each(function(f)
					f(res)
				end)
				jar.update_jar(req.url, res)

				-- Report entry inserted BEFORE ui.update() - ui.update()
				-- synchronously re-renders every pane, Report included, so
				-- inserting after it means every render (this one and any
				-- later one that never gets re-triggered) permanently
				-- lags one entry behind, missing the one that was just
				-- added. Confirmed directly: report_entries itself always
				-- had the correct final count right after the loop, but
				-- the very LAST entry's own render fired before its
				-- insert - only masked on the first-ever run, where the
				-- trailing open_report()'s BufWinEnter (new buffer
				-- entering a window for the first time) forces one more,
				-- correct render. Every run after that reuses the same
				-- buffer-in-window pairing, BufWinEnter never re-fires,
				-- and that stale one-behind render is what's left
				-- displayed - permanently, since nothing else re-renders
				-- after the loop ends.
				table.insert(report_entries, {
					name = req.name or ("#" .. i),
					method = req.method,
					ok = res.status.code < 400,
					detail = ("%d %s (%dms)"):format(res.status.code, res.status.text, elapsed_ms),
					bufnr = bufnr,
					line = start_row + 1,
				})
				ui.update({ response = res })
			end
		end)

		run_in_progress = false
		if not run_ok then
			vim.notify(("run_all: unexpected error - %s"):format(run_err), vim.log.levels.ERROR, { title = "rest.nvim" })
		end

		-- Not a plain open_report() - that's also what <leader>RR calls
		-- directly, where staying focused in the Report pane so you can
		-- read/navigate it is exactly the point. Here it's an unrequested
		-- auto-preview after a run, and open_report()'s vsplit leaves focus
		-- in the NEW window (unlike toggle_result(), which explicitly
		-- wincmd("p")s back) - so without restoring focus, the .http buffer
		-- silently stops being "current". The next <leader>Ra/Rc would then
		-- run against the Report buffer itself instead: its lines start
		-- with literal GET/POST tokens, so tree-sitter-http partially
		-- misparses the report table AS request sections, producing a
		-- wrong (and, since it never lands back in the real buffer either,
		-- stuck-wrong) request count on every run after the first -
		-- confirmed exactly via a headless repro before this fix.
		vim.schedule(function()
			local prev_win = vim.api.nvim_get_current_win()
			open_report()
			if vim.api.nvim_win_is_valid(prev_win) then
				vim.api.nvim_set_current_win(prev_win)
			end
		end)
	end)
end

local function run_all()
	local parser = require("rest-nvim.parser")
	local bufnr = vim.api.nvim_get_current_buf()
	local nodes = parser.get_all_request_nodes(bufnr)
	if #nodes == 0 then
		vim.notify("No requests found in buffer", vim.log.levels.WARN, { title = "rest.nvim" })
		return
	end
	run_nodes(bufnr, nodes)
end

---Debugger-style "run to cursor": runs every request from the top of the
---buffer through (and including) the one under the cursor, then stops -
---rebuilds a chain's state (globals a later post-request script depends on)
---up through the request actually being debugged, without also firing every
---request after it.
local function run_to_cursor()
	local parser = require("rest-nvim.parser")
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1 -- 0-indexed, matches TSNode:range()

	-- Deliberately NOT parser.get_request_node_by_cursor() here: it reads
	-- from the buffer's attached treesitter tree (vim.treesitter.get_node())
	-- while get_all_request_nodes() below parses via ts_parser:parse(false)
	-- - "false" reuses the cached tree rather than forcing invalidation.
	-- Right after an edit, those two can briefly disagree on node
	-- boundaries, so comparing node ranges FROM TWO SEPARATE PARSES (as a
	-- past version of this did) could silently mismatch and cut the loop
	-- short. Using containment against ONE parse's ranges instead removes
	-- that gap entirely - there's nothing left to disagree with.
	local nodes = {}
	local found = false
	for _, node in ipairs(parser.get_all_request_nodes(bufnr)) do
		table.insert(nodes, node)
		local start_row, _, end_row = node:range()
		if cursor_row >= start_row and cursor_row <= end_row then
			found = true
			break
		end
	end

	if not found then
		vim.notify("No request under cursor", vim.log.levels.WARN, { title = "rest.nvim" })
		return
	end
	run_nodes(bufnr, nodes)
end

return {
	"rest-nvim/rest.nvim",
	ft = "http",
	cmd = "Rest",
	dependencies = {
		{
			"j-hui/fidget.nvim",
			-- Pure rest.nvim dependency here (nothing else in this config
			-- uses fidget - grep confirms) - client/curl/cli.lua fires one
			-- of these per request via fidget.progress.handle, which pops a
			-- toast per request. With run_all() firing several in a row and
			-- the Report tab already showing the same info, that's just
			-- noise. fidget.progress.suppress() only gates its LSP-polling
			-- path, not these direct handle:report()/notification.notify()
			-- calls (checked handle.lua - they bypass it entirely), so the
			-- notification-level filter is the actual lever: all of
			-- fidget's progress messages report at vim.log.levels.INFO
			-- (progress.lua's format_progress, hardcoded), so raising the
			-- filter above that silences them while leaving fidget itself
			-- (and rest.nvim's require("fidget.progress")) working.
			config = function()
				require("fidget").setup({
					notification = { filter = vim.log.levels.OFF },
				})
			end,
		},
		"nvim-neotest/nvim-nio",
		{
			"manoelcampos/xml2lua",
			config = function(plugin)
				package.path = package.path .. ";" .. plugin.dir .. "/?.lua"
			end,
		},
		{
			"lunarmodules/lua-mimetypes",
			config = function(plugin)
				package.path = package.path .. ";" .. plugin.dir .. "/?.lua"
			end,
		},
	},
	keys = {
		{ "<leader>Rs", "<cmd>Rest run<cr>",        desc = "[R]equest [S]end" },
		{ "<leader>Ra", run_all,                    desc = "[R]equest Send [A]ll" },
		{ "<leader>Rc", run_to_cursor,              desc = "[R]equest Run To [C]ursor" },
		{ "<leader>Rl", "<cmd>Rest last<cr>",       desc = "[R]equest Rerun [L]ast" },
		{ "<leader>Ro", toggle_result,              desc = "[R]equest [O]pen Window" },
		{ "<leader>Re", "<cmd>Rest env select<cr>", desc = "[R]equest Select [E]nvironment" },
		{ "<leader>Rv", "<cmd>Rest env show<cr>",   desc = "[R]equest [V]iew Environment" },
		{ "<leader>Ry", "<cmd>Rest curl yank<cr>",  desc = "[R]equest Cop[y] As cURL" },
		{ "<leader>Ri", inspect,                    desc = "[R]equest [I]nspect" },
		{ "<leader>RR", open_report,                desc = "[R]equest [R]eport" },
	},
	config = function()
		install_report_tab()

		vim.g.rest_nvim = {
			env = {
				enable = true,
				pattern = "%.env.*",
			},
			ui = {
				winbar = true,
			},
		}

		-- response.hooks.format (default on) shells out to `gq` on a fresh
		-- scratch buffer with filetype set to the response type (e.g.
		-- "json") - gq only does anything if that buffer's formatprg/
		-- formatexpr is set, and a scratch buffer has neither by default
		-- (verified directly in utils.gq_lines: no formatexpr/formatprg ->
		-- format is silently skipped, and the "# @_RES" marker in the
		-- result pane loses its "(formatted)" suffix). This is what was
		-- read as "JQ filtering is gone" / unformatted JSON bodies - give
		-- json buffers (including this throwaway one) a formatexpr so gq
		-- has something to run. Also fixes `gq` in real .json files.
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "json",
			group = vim.api.nvim_create_augroup("RestNvimJsonFormat", { clear = true }),
			callback = function()
				vim.bo.formatexpr = "v:lua.rest_nvim_json_formatexpr()"
			end,
		})

		-- `:Rest open` (result pane) and its Headers/Cookies/Statistics
		-- panes are real splits sharing filetype "rest_nvim_result"
		-- (ui/result.lua's create_pane_group on_init), not floats -
		-- :mksession captures them like any other window. On restore
		-- rest.nvim's own pane setup never reruns, so they come back as
		-- dead plain buffers. Same fix as nvim-tree's PersistenceSavePre
		-- handler in plugins/tree.lua: close them before persistence.nvim
		-- saves so they're never in the session to begin with.
		vim.api.nvim_create_autocmd("User", {
			pattern = "PersistenceSavePre",
			group = vim.api.nvim_create_augroup("RestNvimSessionFilter", { clear = true }),
			callback = close_rest_windows,
		})
	end,
}
