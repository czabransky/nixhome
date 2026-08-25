local M = {}

function M.core()
	return {
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
		},
		event = "VeryLazy",
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()
			require("nvim-dap-virtual-text").setup()

			-- netcoredbg (nix package) - .NET/C# debugging. No dap.configurations.cs
			-- here for the same reason as JS: .vscode/launch.json is read
			-- automatically on-demand (:help dap-providers), so per-project
			-- launch/attach targets stay out of dotfiles.
			dap.adapters.coreclr = {
				type = "executable",
				command = "netcoredbg",
				args = { "--interpreter=vscode" },
			}

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- .vscode/launch.json is read automatically on-demand (:help dap-providers),
			-- so per-project attach targets (monorepo apps, docker backends) stay out of dotfiles.
			vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "[D]ebug [C]ontinue" })
			vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "[D]ebug Run [L]ast" })
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "[D]ebug Toggle [B]reakpoint" })
			vim.keymap.set("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "[D]ebug Conditional [B]reakpoint" })
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
