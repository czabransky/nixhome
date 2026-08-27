-- ARCHIVED - not loaded (no longer required from lazy.lua). Kept for
-- reference/possible revival; wasn't working reliably, being replaced by
-- rest.nvim for .http/.rest requests.
--
-- https://github.com/mistweaverco/kulala.nvim
-- HTTP client for .http/.rest files (JetBrains .http spec). No special glue
-- needed to use it alongside nvim-dap: launch/attach the debugger (dap.lua)
-- as normal, set breakpoints, then send a request from here - it's the same
-- running process, so the breakpoint just gets hit.
return {
	"mistweaverco/kulala.nvim",
	ft = { "http", "rest" },
	config = function()
		require("kulala").setup({
			global_keymaps = false,
			-- Without this, {{name.response.body.$.path}} request-variable
			-- chaining (see Hexora.Api.http) silently resolves to nothing -
			-- JSON pretty-printing in the Body view is a separate built-in
			-- feature (kulala-core's response_format) and works regardless,
			-- so seeing that doesn't confirm path resolution is wired up.
			-- A Lua function (rather than an external `jq` pathresolver) is
			-- used because kulala passes the raw JSONPath string including
			-- its leading "$." (e.g. "$.accessToken"), which isn't valid jq
			-- filter syntax on its own.
			contenttypes = {
				["application/json"] = {
					ft = "json",
					pathresolver = function(body, path)
						if type(body) ~= "table" then return end
						local value = body
						for segment in path:gmatch("[^%.%[%]\"']+") do
							if segment ~= "$" then
								if type(value) ~= "table" then return end
								value = value[tonumber(segment) or segment]
							end
						end
						return value
					end,
				},
			},
			kulala_core = {
				-- Default 60000ms is a hard vim.system() timeout on the
				-- kulala-core subprocess that actually performs the request
				-- - if a nvim-dap breakpoint on the server side pauses past
				-- that, kulala-core gets killed (exit 124) and reports
				-- "Request timed out"/no response, no matter how the server
				-- eventually resolves. 10 minutes covers realistic
				-- breakpoint-inspection time without disabling the timeout
				-- outright (0 = wait forever on a truly dead request, no
				-- feedback at all).
				timeout = 600000,
			},
			lsp = {
				-- Kulala ships its own built-in LSP for .http/.rest buffers
				-- (documentSymbol/hover/completion/codeAction) but starts it
				-- outside nvim-lspconfig, so it never picks up
				-- lsp-attach.lua's on_attach on its own - without this,
				-- <leader>ss (Search Symbols) and the rest of the shared LSP
				-- keymaps just don't exist here.
				on_attach = require("colin.lsp.lsp-attach").on_attach,
			},
		})

		-- kulala's own response summary (Request/Code/Duration/Time,
		-- URL/Env/Status/Assert, Buffer/Name) applies exactly one
		-- highlight to the whole 3-line block based on overall pass/fail
		-- (report.successHighlight/errorHighlight) - no per-field
		-- styling, and no config hook to add any. This re-colors just
		-- the "Status: NNN" and "Assert: word" values by their own
		-- meaning, independently of that block highlight. Runs on every
		-- buffer change (kulala redraws the summary by replacing all
		-- lines on every request/next/prev/toggle), not just once, since
		-- that replacement doesn't preserve extmarks.
		local kulala_status_ns = vim.api.nvim_create_namespace("kulala_status_hl")

		-- A plain fg-color swap on already-dim summary text is too subtle
		-- to read as a signal at a glance - bold on top of each Diagnostic
		-- color makes it read as a status, not just tinted text. Defined
		-- from the live Diagnostic colors (not hardcoded hex) and
		-- reapplied on ColorScheme so it survives <leader>sT.
		local function setup_kulala_status_hls()
			for name, source in pairs({
				KulalaStatusOk = "DiagnosticOk",
				KulalaStatusWarn = "DiagnosticWarn",
				KulalaStatusError = "DiagnosticError",
			}) do
				local src = vim.api.nvim_get_hl(0, { name = source, link = false })
				vim.api.nvim_set_hl(0, name, vim.tbl_extend("force", src, { bold = true }))
			end
		end
		setup_kulala_status_hls()
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("UserKulalaStatusHl", { clear = true }),
			callback = setup_kulala_status_hls,
		})

		local function status_hl(code)
			local n = tonumber(code)
			if not n then return "KulalaStatusError" end
			if n < 300 then return "KulalaStatusOk" end
			if n < 400 then return "KulalaStatusWarn" end
			return "KulalaStatusError"
		end

		-- Generic passes over the whole summary block, lower priority than
		-- the semantic Status/Assert coloring below so those still win
		-- where they overlap (e.g. the status code digits themselves).
		-- highlight_numbers takes an optional [skip_from, skip_to) range
		-- (0-indexed cols) to leave untouched - Neovim doesn't cleanly
		-- resolve two overlapping extmarks by priority the way you'd
		-- expect (the URL's own color kept losing to Number's on the
		-- digits inside it, e.g. :5000, /v1/, even at a higher priority),
		-- so this sidesteps that entirely by never overlapping them in the
		-- first place rather than relying on priority to resolve it.
		local function highlight_numbers(buf, row, text, skip_from, skip_to)
			local init = 1
			while true do
				local s, e = text:find("%d+%.?%d*", init)
				if not s then break end
				local col = s - 1
				local inside_skip = skip_from and col >= skip_from and e <= skip_to
				if not inside_skip then
					pcall(vim.api.nvim_buf_set_extmark, buf, kulala_status_ns, row, col, {
						end_col = e,
						hl_group = "Number",
						priority = 150,
					})
				end
				init = e + 1
			end
		end

		local function highlight_url(buf, row, text)
			local s, e = text:find("https?://%S+")
			if s then
				pcall(vim.api.nvim_buf_set_extmark, buf, kulala_status_ns, row, s - 1, {
					end_col = e,
					hl_group = "@markup.link.url",
					priority = 150,
				})
				return s - 1, e -- 0-indexed [from, to) for highlight_numbers to skip
			end
		end

		local function highlight_kulala_summary(buf)
			vim.api.nvim_buf_clear_namespace(buf, kulala_status_ns, 0, 4)
			local ok, lines = pcall(vim.api.nvim_buf_get_lines, buf, 0, 3, false)
			if not ok then return end

			local text = lines[2] -- "URL: ... Status: NNN  Assert: word"
			local url_from, url_to
			if text then
				url_from, url_to = highlight_url(buf, 1, text)
			end

			for row, line in ipairs(lines) do
				local zrow = row - 1
				highlight_numbers(buf, zrow, line, zrow == 1 and url_from or nil, zrow == 1 and url_to or nil)
			end
			if not text then return end

			local s, _, status = text:find("Status: (%S+)")
			if s then
				local col = s + 7 -- byte length of "Status: "
				pcall(vim.api.nvim_buf_set_extmark, buf, kulala_status_ns, 1, col, {
					end_col = col + #status,
					hl_group = status_hl(status),
					priority = 200,
				})
			end

			local a, _, assert_word = text:find("Assert: (%S+)")
			local assert_hl = assert_word == "success" and "KulalaStatusOk"
				or assert_word == "failed" and "KulalaStatusError"
				or nil
			if a and assert_hl then
				local col = a + 7 -- byte length of "Assert: "
				pcall(vim.api.nvim_buf_set_extmark, buf, kulala_status_ns, 1, col, {
					end_col = col + #assert_word,
					hl_group = assert_hl,
					priority = 200,
				})
			end
		end

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "kulala_ui",
			callback = function(ev)
				highlight_kulala_summary(ev.buf)
				vim.api.nvim_buf_attach(ev.buf, false, {
					on_lines = function()
						vim.schedule(function()
							if vim.api.nvim_buf_is_valid(ev.buf) then highlight_kulala_summary(ev.buf) end
						end)
					end,
				})
			end,
		})

		local kulala = require("kulala")
		vim.keymap.set("n", "<leader>Rs", kulala.run, { desc = "[R]equest [S]end" })
		vim.keymap.set("n", "<leader>Ra", kulala.run_all, { desc = "[R]equest Send [A]ll" })
		vim.keymap.set("n", "<leader>Rr", kulala.replay, { desc = "[R]equest [R]eplay Last" })
		vim.keymap.set("n", "<leader>Rb", kulala.scratchpad, { desc = "[R]equest Scratchpad ([B])" })
		vim.keymap.set("n", "<leader>Re", kulala.set_selected_env, { desc = "[R]equest Select [E]nvironment" })
		vim.keymap.set("n", "<leader>Ro", kulala.open, { desc = "[R]equest [O]pen Window" })
		vim.keymap.set("n", "<leader>RO", function()
			-- kulala.open() (above) creates/updates the results window but
			-- opens it unfocused (nvim_open_win(..., false, ...)) - this
			-- does the same, then jumps the cursor straight in.
			kulala.open()
			vim.schedule(function()
				local win = require("kulala.ui").get_kulala_window()
				if win then vim.api.nvim_set_current_win(win) end
			end)
		end, { desc = "[R]equest [O]pen + Focus Window" })
		vim.keymap.set("n", "<leader>Ri", kulala.inspect, { desc = "[R]equest [I]nspect" })
		vim.keymap.set("n", "<leader>Rn", kulala.jump_next, { desc = "[R]equest Jump [N]ext" })
		vim.keymap.set("n", "<leader>Rp", kulala.jump_prev, { desc = "[R]equest Jump [P]revious" })
	end,
}
