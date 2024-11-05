return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      layout_strategy = "horizontal",
      layout_config = {
        prompt_position = "top",
        horizontal = { mirror = false },
        vertical = { mirror = false },
      },
      sorting_strategy = "ascending",
    },
  },
}
