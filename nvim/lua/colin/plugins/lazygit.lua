-- https://github.com/kdheepak/lazygit.nvim
return {
	"kdheepak/lazygit.nvim",
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},
	keys = {
		-- Diff against a branch/commit: select it in the Branches/Commits
		-- panel and press `d` there.
		{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
		{ "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "Open LazyGit Filtered to Current File" },
	},
}
