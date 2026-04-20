return {
    "seblyng/roslyn.nvim",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
		ignore_target = function(target)
			return string.match(target, "Unified.sln") ~= nil
		end
    },
}