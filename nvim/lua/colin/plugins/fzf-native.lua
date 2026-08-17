-- https://github.com/nvim-telescope/telescope-fzf-native.nvim
-- Declared as its own top-level spec (rather than nested under telescope's
-- dependencies) so lazy.nvim reliably runs the `build` step on install —
-- as a nested dependency the native lib never got compiled, leaving
-- telescope's fzf syntax (!, ^, $) silently non-functional.
return {
	"nvim-telescope/telescope-fzf-native.nvim",
	build = "make",
	cond = vim.fn.executable("make") == 1,
}
