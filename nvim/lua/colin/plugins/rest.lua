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

-- A literal tab on the SAME "rest_nvim_result" pane group (cycling via the
-- built-in H/L keys alongside Response/Headers/Cookies/Statistics) turns out
-- not to be cleanly reachable: ui/panes.lua's create_pane_group() errors on
-- a name that's already registered, and the module-level table it's stored
-- in has no public getter - only reachable by pulling the "groups" upvalue
-- off paneui.winbar via the debug library, and even then, appending a pane
-- means hand-copying create_pane_group's private per-pane construction
-- logic (buffer creation, modifiable toggling, on_init wiring) rather than
-- calling any public API for it. That's reimplementing plugin internals
-- rest.nvim doesn't own as a stable interface, on a young plugin whose
-- internals are still actively moving - too fragile for what it buys here.
-- This instead builds the Report as its own pane GROUP via the same public
-- rest-nvim.ui.panes API the built-in panes use, so it looks and behaves
-- the same (winbar styling, RestPaneTitle highlight) even though it opens
-- in its own window rather than literally inside the existing one.
local report_group ---@type rest.ui.panes.PaneGroup?

local function ensure_report_hl()
	for name, source in pairs({ RestReportOk = "DiagnosticOk", RestReportError = "DiagnosticError" }) do
		local src = vim.api.nvim_get_hl(0, { name = source, link = false })
		vim.api.nvim_set_hl(0, name, vim.tbl_extend("force", src, { bold = true }))
	end
end

local function build_report_group()
	ensure_report_hl()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("RestNvimReportHl", { clear = true }),
		callback = ensure_report_hl,
	})

	local paneui = require("rest-nvim.ui.panes")
	local ns = vim.api.nvim_create_namespace("rest_nvim_report")
	return paneui.create_pane_group("rest_nvim_report", {
		{
			name = "Report",
			on_init = function(self)
				-- Matches the "^rest_nvim" pattern the PersistenceSavePre
				-- handler below filters on, same as the built-in panes.
				vim.bo[self.bufnr].filetype = "rest_nvim_report"
				vim.keymap.set("n", "<cr>", function()
					local entry = report_entries[vim.api.nvim_win_get_cursor(0)[1]]
					if not entry then
						return
					end
					vim.cmd.wincmd("p")
					vim.api.nvim_set_current_buf(entry.bufnr)
					vim.api.nvim_win_set_cursor(0, { entry.line, 0 })
				end, { buffer = self.bufnr, nowait = true, desc = "Jump to request" })
				for _, lhs in ipairs({ "q", "<esc>" }) do
					vim.keymap.set("n", lhs, "<cmd>close<cr>", { buffer = self.bufnr, nowait = true, silent = true })
				end
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

				local lines = {}
				local passed = 0
				for _, entry in ipairs(report_entries) do
					if entry.ok then
						passed = passed + 1
					end
					table.insert(
						lines,
						("[%s] %-6s %-30.30s %s"):format(entry.ok and "PASS" or "FAIL", entry.method, entry.name, entry.detail)
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
		},
	})
end

---Open (or refresh, if already open) the Report pane in a vertical split.
local function open_report()
	report_group = report_group or build_report_group()
	local pane = report_group.panes[1]
	local winid = pane.bufnr and vim.fn.bufwinid(pane.bufnr) or -1
	if winid == -1 then
		vim.cmd("vsplit")
		winid = vim.api.nvim_get_current_win()
	end
	report_group:enter(winid)
	-- :enter() only (re)renders when the pane buffer doesn't already exist -
	-- force a render so a second run_all()'s results actually show up.
	pane:render()
end

local function run_all()
	local parser = require("rest-nvim.parser")
	local Context = require("rest-nvim.context").Context
	local config = require("rest-nvim.config")
	local clients = require("rest-nvim.client")
	local jar = require("rest-nvim.cookie_jar")
	local ui = require("rest-nvim.ui.result")

	local bufnr = vim.api.nvim_get_current_buf()
	local nodes = parser.get_all_request_nodes(bufnr)
	if #nodes == 0 then
		vim.notify("No requests found in buffer", vim.log.levels.WARN, { title = "rest.nvim" })
		return
	end

	report_entries = {}

	require("nio").run(function()
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
			ui.update({ response = res })

			table.insert(report_entries, {
				name = req.name or ("#" .. i),
				method = req.method,
				ok = res.status.code < 400,
				detail = ("%d %s (%dms)"):format(res.status.code, res.status.text, elapsed_ms),
				bufnr = bufnr,
				line = start_row + 1,
			})
		end

		vim.schedule(open_report)
	end)
end

return {
	"rest-nvim/rest.nvim",
	ft = "http",
	cmd = "Rest",
	dependencies = {
		"j-hui/fidget.nvim",
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
		{ "<leader>Rs", "<cmd>Rest run<cr>", desc = "[R]equest [S]end" },
		{ "<leader>Ra", run_all, desc = "[R]equest Send [A]ll" },
		{ "<leader>Rl", "<cmd>Rest last<cr>", desc = "[R]equest Rerun [L]ast" },
		{ "<leader>Ro", toggle_result, desc = "[R]equest [O]pen Window" },
		{ "<leader>Re", "<cmd>Rest env select<cr>", desc = "[R]equest Select [E]nvironment" },
		{ "<leader>Rv", "<cmd>Rest env show<cr>", desc = "[R]equest [V]iew Environment" },
		{ "<leader>Ry", "<cmd>Rest curl yank<cr>", desc = "[R]equest Cop[y] As cURL" },
		{ "<leader>Ri", inspect, desc = "[R]equest [I]nspect" },
		{ "<leader>RR", open_report, desc = "[R]equest [R]eport" },
	},
	config = function()
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
		-- json buffers (including this throwaway one) a formatprg so gq has
		-- something to run. Also fixes `gq` in real .json files.
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "json",
			group = vim.api.nvim_create_augroup("RestNvimJsonFormat", { clear = true }),
			callback = function()
				vim.bo.formatprg = "jq ."
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
