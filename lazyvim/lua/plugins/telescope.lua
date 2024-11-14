return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      layout_strategy = "vertical",
      layout_config = {
        prompt_position = "top",
        vertical = { mirror = true },
        width = 0.9,
      },
      sorting_strategy = "ascending",
    },
  },
}
