-- https://github.com/stevearc/overseer.nvim
-- Task runner for one-off/repeatable shell commands (dotnet test, builds,
-- etc.), with output captured per-task instead of a bare :terminal buffer.
-- "vscode" template loader picks up a project's own .vscode/tasks.json with
-- no config-side registration; "builtin" adds generic templates like
-- "run shell command" and language-specific make/cargo/etc. detection.
return {
	"stevearc/overseer.nvim",
	config = function()
		require("overseer").setup({
			templates = { "builtin", "vscode" },
		})

		local overseer = require("overseer")
		vim.keymap.set("n", "<leader>or", overseer.run_task, { desc = "[O]verseer [R]un Task" })
		vim.keymap.set("n", "<leader>oc", "<cmd>OverseerShell<cr>", { desc = "[O]verseer Run [C]ommand" })
		vim.keymap.set("n", "<leader>oo", overseer.toggle, { desc = "[O]verseer [O]pen/Close" })
		vim.keymap.set("n", "<leader>oa", "<cmd>OverseerTaskAction<cr>", { desc = "[O]verseer Task [A]ction" })
		-- No standalone "restart last" command exists; restart is a per-task
		-- action reached via OverseerTaskAction's picker. This grabs the most
		-- recently created task (list_tasks sorts newest-first by default)
		-- and restarts it directly, skipping the picker for a fast re-run.
		vim.keymap.set("n", "<leader>ol", function()
			local task = overseer.list_tasks()[1]
			if task then
				task:restart(true)
			else
				vim.notify("No overseer tasks to restart", vim.log.levels.WARN)
			end
		end, { desc = "[O]verseer Restart [L]ast" })
	end,
}
