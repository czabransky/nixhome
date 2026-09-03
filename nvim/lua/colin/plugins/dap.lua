local M = {}

function M.core()
	return {
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
			-- Actual setup() lives in plugins/fidget.lua (shared with
			-- rest.nvim) - just needed here so it's loaded by the time the
			-- coreclr adapter below reaches for fidget.progress.
			"j-hui/fidget.nvim",
		},
		event = "VeryLazy",
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()
			require("nvim-dap-virtual-text").setup()

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
				-- Attach targets an already-running process by pid - there's
				-- nothing to build, and rebuilding first risks the binary on
				-- disk no longer matching what's actually executing.
				if config.request == "attach" then
					cb({ type = "executable", command = "netcoredbg", args = { "--interpreter=vscode" } })
					return
				end
				local cwd = config.cwd or vim.loop.cwd()
				local output = {}
				-- lsp_client name distinguishes this from rest.nvim's own
				-- fidget.progress handles for plugins/fidget.lua's
				-- notification.redirect filter - see that file for why.
				local handle = require("fidget.progress").handle.create({
					title = "dotnet build",
					message = cwd,
					lsp_client = { name = "dap" },
				})
				vim.fn.jobstart({ "dotnet", "build" }, {
					cwd = cwd,
					stdout_buffered = true,
					stderr_buffered = true,
					on_stdout = function(_, data) vim.list_extend(output, data) end,
					on_stderr = function(_, data) vim.list_extend(output, data) end,
					on_exit = function(_, code)
						handle:finish()
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

			-- Multi-session adapters (JS debugging in particular: a
			-- node-terminal/pwa-node launch spawns a lightweight root
			-- session that hands off to a child session via
			-- vscode-js-debug's "attachedChildSession" reverse request) can
			-- terminate/exit one session while another is still live -
			-- closing dapui unconditionally on ANY session's
			-- event_terminated/event_exited causes it to flash open then
			-- shut immediately when the root session finishes its handoff
			-- before the real (child) debuggee session has even started.
			-- Only close once nothing else is left running.
			local function close_dapui_if_last_session(closing_session)
				local remaining = vim.tbl_filter(function(s)
					return s ~= closing_session
				end, dap.sessions())
				if vim.tbl_isempty(remaining) then
					dapui.close()
				end
			end

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = close_dapui_if_last_session
			dap.listeners.before.event_exited["dapui_config"] = close_dapui_if_last_session

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
			local function set_conditional_breakpoint()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end

			-- Attach-based debugging (start the process yourself, point the
			-- debugger at it afterward) sidesteps most of the fragility in
			-- launch-based JS/.NET configs - no launcher, no auto-attach
			-- handshake, just a single connection to something already
			-- running. nvim-dap's own dap.utils.pick_process lists EVERY
			-- process, which for `dotnet watch` or `pnpm dev` means several
			-- wrapper/supervisor layers on top of the one process that's
			-- actually debuggable (dotnet watch run -> dotnet-watch.dll ->
			-- dotnet run --no-build -> the real compiled app; pnpm -> node),
			-- making it genuinely hard to tell which entry is the right one.
			-- debuggable_leaf_processes narrows to processes matching a
			-- pattern AND having no matching child of their own - i.e. only
			-- the bottom of each wrapper chain, which is always the one
			-- actually worth attaching to.
			local function debuggable_leaf_processes(cmd_matches)
				local by_pid = {}
				for _, line in ipairs(vim.fn.systemlist({ "ps", "-eo", "pid,ppid,command" })) do
					local pid, ppid, command = line:match("^%s*(%d+)%s+(%d+)%s+(.*)$")
					if pid then
						by_pid[tonumber(pid)] = { pid = tonumber(pid), ppid = tonumber(ppid), command = command }
					end
				end
				local matched = {}
				for pid, proc in pairs(by_pid) do
					if cmd_matches(proc.command) then
						matched[pid] = proc
					end
				end
				local has_matched_child = {}
				for _, proc in pairs(matched) do
					if matched[proc.ppid] then
						has_matched_child[proc.ppid] = true
					end
				end
				local leaves = {}
				for pid, proc in pairs(matched) do
					if not has_matched_child[pid] then
						table.insert(leaves, proc)
					end
				end
				table.sort(leaves, function(a, b) return a.pid < b.pid end)
				return leaves
			end

			local function process_label(proc)
				local exe = proc.command:match("^%S+") or proc.command
				local basename = exe:match("([^/\\]+)$") or exe
				return string.format("%s (pid %d) - %s", basename, proc.pid, proc.command)
			end

			local function pick_leaf_process(cmd_matches, prompt, on_pick)
				local candidates = debuggable_leaf_processes(cmd_matches)
				if #candidates == 0 then
					vim.notify("No matching running process found", vim.log.levels.WARN)
					return
				end
				vim.ui.select(candidates, { prompt = prompt, format_item = process_label }, function(choice)
					if choice then
						on_pick(choice.pid)
					end
				end)
			end

			local function attach_to_process()
				vim.ui.select({ "Node.js", ".NET" }, { prompt = "Attach to running process - language:" }, function(lang)
					if not lang then
						return
					end

					if lang == ".NET" then
						-- The compiled app always runs from bin/Debug|Release/<tfm>/ -
						-- unlike "dotnet watch run"/dotnet-watch.dll/MSBuild.dll, which
						-- never do - so this alone, combined with the leaf-only
						-- filtering above, reliably isolates the real running app.
						pick_leaf_process(function(cmd)
							return cmd:match("/bin/Debug/") ~= nil or cmd:match("/bin/Release/") ~= nil
						end, "Attach to .NET process:", function(pid)
							dap.run({
								type = "coreclr",
								request = "attach",
								name = "Attach to process " .. pid,
								processId = pid,
							})
						end)
						return
					end

					local port_input = vim.fn.input("Inspector port to attach to (blank to pick a running process instead): ")
					local attach_config = {
						type = "pwa-node",
						request = "attach",
						cwd = vim.loop.cwd(),
						-- Node's --watch (or nodemon, etc.) restarts the process
						-- out from under an active attach session; without this
						-- the session just dies on the first restart instead of
						-- reconnecting to the new one.
						restart = true,
						skipFiles = { "<node_internals>/**" },
						-- We're attaching to one already-running process, not
						-- orchestrating a tree of them - don't try to also
						-- auto-attach anything it spawns. (Doesn't silence
						-- every child-process message: a process that spins up
						-- its own worker_threads under --inspect - e.g.
						-- BullMQ's queue workers - can still log a one-off
						-- "connect ENOENT .../node-cdp-*.sock" from Node's own
						-- internal worker-inspector handshake. Harmless -
						-- confirmed the main attach session stays up and usable
						-- either way - just noisy.)
						autoAttachChildProcesses = false,
					}
					if port_input ~= "" then
						attach_config.name = "Attach to port " .. port_input
						attach_config.port = tonumber(port_input)
						attach_config.address = "localhost"
						dap.run(attach_config)
						return
					end
					-- SIGUSR1-based runtime inspector activation (what a bare
					-- attach-by-pid relies on for a process not already started
					-- with --inspect) is POSIX-only - use the port prompt above
					-- on Windows instead.
					pick_leaf_process(function(cmd)
						return cmd:match("^%S*/node%s") ~= nil or cmd:match("^node%s") ~= nil or cmd == "node"
					end, "Attach to Node process:", function(pid)
						attach_config.name = "Attach to process " .. pid
						attach_config.processId = pid
						dap.run(attach_config)
					end)
				end)
			end

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
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "[D]ebug Toggle [B]reakpoint" })
			vim.keymap.set("n", "<leader>dB", set_conditional_breakpoint, { desc = "[D]ebug Conditional [B]reakpoint" })
			vim.keymap.set("n", "<leader>dk", dap.toggle_breakpoint, { desc = "[D]ebug Toggle Brea[k]point" })
			vim.keymap.set("n", "<leader>dK", set_conditional_breakpoint, { desc = "[D]ebug Conditional Brea[k]point" })
			vim.keymap.set("n", "<leader>dC", dap.clear_breakpoints, { desc = "[D]ebug [C]lear All Breakpoints" })
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
			vim.keymap.set("n", "<leader>da", attach_to_process, { desc = "[D]ebug [A]ttach to Running Process" })
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
			-- nvim-dap-vscode-js's child-session handoff (adapter.lua's
			-- start_child_session, used whenever vscode-js-debug sends an
			-- "attachedChildSession" reverse request - the mechanism
			-- node-terminal/pwa-node auto-attach relies on to give you a
			-- real, breakpoint-capable session for the actual Node process,
			-- as opposed to the lightweight coordinator/terminal session)
			-- calls `require("dap.session"):connect(adapter, opts, on_connect)`
			-- with COLON syntax and only 3 args. nvim-dap's actual signature
			-- is `Session.connect(adapter, config, opts, on_connect)` - 4
			-- params, DOT-defined. The colon call silently prepends the
			-- Session module table itself as an extra leading arg, so
			-- everything shifts one slot: `adapter` becomes the Session
			-- module (no .host/.port), the real adapter table lands in
			-- `config` instead, and `on_connect` is the only thing that
			-- still (coincidentally) lines up. The child session's own
			-- connect then dies on `assert(tonumber(adapter.port), ...)` -
			-- asynchronously, inside a raw libuv getaddrinfo callback the
			-- surrounding pcall doesn't cover, so it fails with no visible
			-- error. Net effect: the child session (the one with real
			-- breakpoints/scopes/stacks) never connects, while dapui still
			-- flickers open/closed off the coordinator session's own
			-- lifecycle - exactly the "no errors, but dapui comes up empty"
			-- symptom this was chasing. Confirmed directly: replaying
			-- adapter.lua's exact call pattern shows adapter.host/port
			-- missing before this patch, present after.
			--
			-- start_child_session and its adapter_config() are local
			-- (non-exported) in adapter.lua, so they can't be reached
			-- directly - patching nvim-dap's own Session.connect to detect
			-- and un-shift this one specific misuse (identified
			-- unambiguously: no legitimate caller ever passes the Session
			-- module table itself as a real adapter) is the smallest fix
			-- that doesn't require reimplementing adapter.lua wholesale.
			local Session = require("dap.session")
			local original_connect = Session.connect
			Session.connect = function(adapter, config, opts, on_connect)
				if adapter == Session then
					adapter, config, opts, on_connect = config, {}, opts, on_connect
				end
				return original_connect(adapter, config, opts, on_connect)
			end

			local debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"
			require("dap-vscode-js").setup({
				debugger_path = debugger_path,
				-- debugger_cmd override needed: nvim-dap-vscode-js's own
				-- entrypoint guess (utils.lua's debugger_entrypoint(), used
				-- whenever debugger_cmd is unset) hardcodes
				-- "out/src/vsDebugServer.js" - that file hasn't existed in
				-- vscode-js-debug since 1.76.1 (renamed/replaced by
				-- dapDebugServer.js, matching M.js_debug()'s own build
				-- command above: `gulp dapDebugServer`). Confirmed via
				-- mxsdev/nvim-dap-vscode-js#57 (open, unresolved upstream)
				-- - the fix on our side is providing the real path
				-- directly; debugger_cmd takes precedence over
				-- debugger_path/node_path entirely (utils.lua's
				-- get_spawn_cmd), so this is a straight substitute for the
				-- "node <entrypoint>" it would otherwise have guessed.
				-- Plain { node, dapDebugServer.js } isn't enough on its own:
				-- unlike the old vsDebugServer.js, dapDebugServer.js always
				-- prints a full sentence to stdout ("Debug server listening
				-- at ::1:8123"), never a bare port number - confirmed via
				-- its source (src/dapDebugServer.ts). utils.lua's
				-- start_debugger() takes nvim-dap-vscode-js's ENTIRE first
				-- stdout chunk as the port value with no parsing
				-- (`chunk:gsub("\n", "")`), so it was handed that whole
				-- sentence as "the port" - hence nvim-dap's "adapter.port is
				-- required for server adapter". Routing through `sh -c` lets
				-- a sed filter strip everything but the trailing digits
				-- before nvim-dap-vscode-js ever reads it. Also pass 0
				-- instead of a fixed port so the OS picks a free one each
				-- launch - dapDebugServer.js defaults to a hardcoded 8123
				-- otherwise, which is what caused the earlier EADDRINUSE
				-- (any two overlapping/uncleaned sessions collide on it).
				--
				-- Explicit 127.0.0.1 host arg matters too: dapDebugServer.js
				-- defaults its bind host to "localhost", which resolves to
				-- ::1 (IPv6) on this machine - but dap-vscode-js's own
				-- adapter.lua hardcodes host = "127.0.0.1" (IPv4) when it
				-- tells nvim-dap where to connect. Without this, the sed
				-- filter above (correctly) hands back a clean port number,
				-- but nvim-dap then dials 127.0.0.1:<port> while the actual
				-- listener is on [::1]:<port> - a different socket - and the
				-- session fails with "Couldn't connect ... ECONNREFUSED".
				-- Confirmed by directly spawning with this exact debugger_cmd
				-- and TCP-connecting to the returned port: fails without the
				-- explicit host arg, succeeds with it.
				debugger_cmd = {
					"sh",
					"-c",
					("node %s 0 127.0.0.1 | sed -un -E 's/.*:([0-9]+)$/\\1/p'"):format(
						vim.fn.shellescape(debugger_path .. "/out/src/dapDebugServer.js")
					),
				},
				adapters = { "pwa-node", "pwa-chrome", "node-terminal" },
			})

			-- dapDebugServer.js is a multi-session TCP server: the FIRST
			-- connection (our debugger_cmd spawn above) is the coordinator,
			-- and it expects any child target (auto-attached Node child
			-- process, a spawned browser tab, etc.) to connect back on a
			-- SECOND connection to that SAME coordinator, carrying a
			-- __pendingTargetId it handed out via the standard DAP
			-- "startDebugging" reverse request (dapDebugServer.ts's
			-- DapSessionManager.acquireDap/handleConnection - each running
			-- coordinator process tracks its own pending targets and 404s
			-- ("Cannot find pending target for <id>") on anything else).
			-- nvim-dap has NATIVE "startDebugging" support (session.lua's
			-- start_debugging) that's specifically built to reuse the
			-- parent session's own connection in this situation - but only
			-- when the freshly resolved child adapter table has a truthy
			-- `.executable` field (see the "Prefer connecting to root
			-- server again" comment in session.lua). nvim-dap-vscode-js's
			-- generated adapters never set `.executable` (always
			-- `type = "server"`, spawned via debugger_cmd), so that reuse
			-- path never triggers - every child target instead spawns a
			-- BRAND NEW, unrelated dapDebugServer.js process via
			-- debugger_cmd, which has no idea what pending target the
			-- original coordinator was tracking. Net effect: any
			-- auto-attached child process (i.e. anything actually worth
			-- debugging) fails with "Cannot find pending target", and the
			-- one thing that stays alive - the lightweight coordinator
			-- session - looks fine right up until it exits, which is why
			-- this showed up as "no errors, but dapui flickers and there's
			-- no running process" rather than a loud failure. Confirmed by
			-- direct repro: a plain pwa-node launch (even a trivial
			-- hello-world script, no conlego/watch/ts-node involved) fails
			-- identically without this, and works - real stdout, real
			-- listening port - with it.
			--
			-- Fix: when nvim-dap invokes one of these adapter functions
			-- WITH a parent session (only ever true for the
			-- startDebugging-triggered child-target call, never the
			-- initial top-level launch), skip spawning entirely and hand
			-- back a placeholder with `.executable = true` so nvim-dap's
			-- own reuse-the-root-connection logic takes over.
			local dap = require("dap")
			for _, mode in ipairs({ "pwa-node", "pwa-chrome", "node-terminal" }) do
				local spawn_new_coordinator = dap.adapters[mode]
				dap.adapters[mode] = function(callback, config, parent_session)
					if parent_session and parent_session.adapter and parent_session.adapter.type == "server" then
						callback({ executable = true })
						return
					end
					spawn_new_coordinator(callback, config, parent_session)
				end
			end
		end,
	}
end

return M
