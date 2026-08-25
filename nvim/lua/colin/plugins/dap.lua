local M = {}

function M.core()
	return {
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
			"Weissle/persistent-breakpoints.nvim",
		},
		event = "VeryLazy",
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()
			require("nvim-dap-virtual-text").setup()

			-- Saves breakpoints (incl. conditions/log messages) to disk and
			-- reloads them into any buffer as it's opened, so they survive
			-- restarting Neovim - core nvim-dap only keeps them in memory.
			-- The <leader>db/<leader>dB keymaps below go through this
			-- plugin's api (not dap.toggle_breakpoint/set_breakpoint
			-- directly) so every set/removal actually gets persisted.
			require("persistent-breakpoints").setup({
				load_breakpoints_event = { "BufReadPost" },
				-- persistence.nvim (plugins/persistence.lua) restores buffers
				-- as part of a session load rather than a plain BufReadPost,
				-- which can skip this plugin's normal reload path - forces it
				-- to reload regardless.
				always_reload = true,
			})

			-- Sign column icons for breakpoints and the current execution line.
			-- nvim-dap references these sign names but never defines them itself.
			vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "CursorLine" })
			local dap_signs = {
				DapBreakpoint = { text = "", texthl = "DiagnosticError" },
				DapBreakpointCondition = { text = "", texthl = "DiagnosticWarn" },
				DapBreakpointRejected = { text = "", texthl = "DiagnosticError" },
				DapLogPoint = { text = "", texthl = "DiagnosticInfo" },
				DapStopped = { text = "", texthl = "DiagnosticWarn", linehl = "DapStoppedLine", numhl = "DiagnosticWarn" },
			}
			for name, sign in pairs(dap_signs) do
				vim.fn.sign_define(name, sign)
			end

			-- netcoredbg (nix package) - .NET/C# debugging. No dap.configurations.cs
			-- here for the same reason as JS: .vscode/launch.json is read
			-- automatically on-demand (:help dap-providers), so per-project
			-- launch/attach targets stay out of dotfiles.
			--
			-- Defined as a function (not a static table): nvim-dap calls
			-- adapter(callback, config) and waits for `callback` before
			-- starting netcoredbg, so a `dotnet build` runs first - .vscode/
			-- launch.json's "request: launch" just execs the prebuilt DLL
			-- directly, with no VSCode-style preLaunchTask to do that for us.
			-- A failed build never calls back, which aborts the session
			-- instead of debugging stale symbols.
			dap.adapters.coreclr = function(cb, config)
				local cwd = config.cwd or vim.loop.cwd()
				local output = {}
				vim.notify("dotnet build (" .. cwd .. ")...", vim.log.levels.INFO)
				vim.fn.jobstart({ "dotnet", "build" }, {
					cwd = cwd,
					stdout_buffered = true,
					stderr_buffered = true,
					on_stdout = function(_, data) vim.list_extend(output, data) end,
					on_stderr = function(_, data) vim.list_extend(output, data) end,
					on_exit = function(_, code)
						if code ~= 0 then
							vim.notify(
								"dotnet build failed (exit " .. code .. "), debug session aborted:\n"
								.. table.concat(output, "\n"),
								vim.log.levels.ERROR
							)
							return
						end
						cb({
							type = "executable",
							command = "netcoredbg",
							args = { "--interpreter=vscode" },
						})
					end,
				})
			end

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- Mute/unmute every breakpoint without deleting them (nvim-dap
			-- has no "disabled" flag on a breakpoint - the DAP protocol
			-- doesn't have one either, so this just remembers the current
			-- set, tells every active session there are none, and restores
			-- them all on the next press). Session-local only, by design -
			-- persisted breakpoints on disk are untouched either way.
			local bp = require("dap.breakpoints")
			local all_disabled = false
			local disabled_snapshot = nil

			local function broadcast_breakpoints(sessions, breakpoints)
				for _, s in pairs(sessions) do
					s:set_breakpoints(breakpoints)
					broadcast_breakpoints(s.children or {}, breakpoints)
				end
			end

			local function toggle_all_breakpoints()
				if all_disabled then
					for bufnr, buf_bps in pairs(disabled_snapshot or {}) do
						for _, b in ipairs(buf_bps) do
							bp.set({ condition = b.condition, hitCondition = b.hitCondition, logMessage = b.logMessage },
								bufnr, b.line)
						end
					end
					broadcast_breakpoints(dap.sessions(), bp.get())
					disabled_snapshot = nil
					all_disabled = false
				else
					disabled_snapshot = bp.get()
					dap.clear_breakpoints()
					all_disabled = true
				end
			end

			-- .vscode/launch.json is read automatically on-demand (:help dap-providers),
			-- so per-project attach targets (monorepo apps, docker backends) stay out of dotfiles.
			local persist = require("persistent-breakpoints.api")

			vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "[D]ebug [C]ontinue" })
			vim.keymap.set("n", "<leader>dL", dap.run_last, { desc = "[D]ebug Run [L]ast" })
			vim.keymap.set("n", "<leader>dl", function()
				-- Same interactive Scopes/Locals tree dapui's sidebar shows
				-- (<CR> expands/collapses, q/<Esc> closes) as a floating
				-- popup instead - no need to have the docked UI open or
				-- navigate windows to reach it. Without an explicit
				-- width/height dapui sizes the float to fit its content and
				-- anchors it at the cursor (a tooltip); passing both plus
				-- position="center" is what actually centers it Telescope-style.
				dapui.float_element("scopes", {
					width = math.floor(vim.o.columns * 0.7),
					height = math.floor(vim.o.lines * 0.8),
					position = "center",
					enter = true,
				})
			end, { desc = "[D]ebug [L]ocals Popup" })
			vim.keymap.set("n", "<leader>db", persist.toggle_breakpoint, { desc = "[D]ebug Toggle [B]reakpoint" })
			vim.keymap.set(
				"n",
				"<leader>dB",
				persist.set_conditional_breakpoint,
				{ desc = "[D]ebug Conditional [B]reakpoint" }
			)
			vim.keymap.set("n", "<leader>dk", persist.toggle_breakpoint, { desc = "[D]ebug Toggle Brea[k]point" })
			vim.keymap.set(
				"n",
				"<leader>dK",
				persist.set_conditional_breakpoint,
				{ desc = "[D]ebug Conditional Brea[k]point" }
			)
			vim.keymap.set("n", "<leader>dC", persist.clear_all_breakpoints, { desc = "[D]ebug [C]lear All Breakpoints" })
			vim.keymap.set(
				"n",
				"<leader>dx",
				toggle_all_breakpoints,
				{ desc = "[D]ebug Toggle All Breakpoints (Enable/Disable)" }
			)
			vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "[D]ebug Step [O]ver" })
			vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "[D]ebug Step [I]nto" })
			vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "[D]ebug Step [O]ut" })
			vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "[D]ebug [T]erminate" })
			vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "[D]ebug [R]EPL Toggle" })
			vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "[D]ebug [U]I Toggle" })
		end,
	}
end

function M.js_debug()
	return {
		"microsoft/vscode-js-debug",
		build = "npm install --legacy-peer-deps --no-save && npx gulp dapDebugServer && mv dist out",
	}
end

function M.js_adapter()
	return {
		"mxsdev/nvim-dap-vscode-js",
		dependencies = { "microsoft/vscode-js-debug" },
		config = function()
			require("dap-vscode-js").setup({
				debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
				adapters = { "pwa-node", "pwa-chrome", "node-terminal" },
			})
		end,
	}
end

return M
