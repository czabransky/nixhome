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
		{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
		{ "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "Open LazyGit Filtered to Current File" },
		-- Same LazyGit entry point as <leader>gg; select a branch/commit in the
		-- Branches/Commits panel and press `d` there to diff against it.
		{ "<leader>gd", "<cmd>LazyGit<cr>", desc = "Open LazyGit (Diff to Branch)" },
	},
}
