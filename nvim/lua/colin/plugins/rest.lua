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

	require("nio").run(function()
		local ctx = Context:new()
		if config.env.enable and vim.b[bufnr]._rest_nvim_env_file then
			ctx:load_file(vim.b[bufnr]._rest_nvim_env_file)
		end

		for i, req_node in ipairs(nodes) do
			local ok, req = pcall(parser.parse, req_node, bufnr, ctx)
			if not ok or not req then
				vim.notify(("run_all: failed to parse request #%d - stopping"):format(i), vim.log.levels.ERROR, { title = "rest.nvim" })
				return
			end

			local client = clients.get_available_clients(req)[1]
			if not client then
				vim.notify(
					("run_all: no client available for %s - stopping"):format(req.name or ("#" .. i)),
					vim.log.levels.ERROR,
					{ title = "rest.nvim" }
				)
				return
			end

			ui.update({ request = req })
			local req_ok, res = pcall(client.request(req).wait)
			if not req_ok then
				vim.notify(
					("run_all: %s failed - stopping chain"):format(req.name or ("#" .. i)),
					vim.log.levels.ERROR,
					{ title = "rest.nvim" }
				)
				return
			end

			vim.iter(req.handlers):each(function(f)
				f(res)
			end)
			jar.update_jar(req.url, res)
			ui.update({ response = res })
		end

		vim.notify(("run_all: ran %d requests"):format(#nodes), vim.log.levels.INFO, { title = "rest.nvim" })
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
		{ "<leader>Ro", "<cmd>Rest open<cr>", desc = "[R]equest [O]pen Window" },
		{ "<leader>Re", "<cmd>Rest env select<cr>", desc = "[R]equest Select [E]nvironment" },
		{ "<leader>Rv", "<cmd>Rest env show<cr>", desc = "[R]equest [V]iew Environment" },
		{ "<leader>Ry", "<cmd>Rest curl yank<cr>", desc = "[R]equest Cop[y] As cURL" },
		{ "<leader>Ri", inspect, desc = "[R]equest [I]nspect" },
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
			callback = function()
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					if vim.bo[buf].filetype:match("^rest_nvim") then
						pcall(vim.api.nvim_win_close, win, true)
					end
				end
			end,
		})
	end,
}
