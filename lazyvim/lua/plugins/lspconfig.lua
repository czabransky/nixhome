return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ruff = {
        settings = {
          args = {
            "--line-length=120",
          },
        },
      },
      bashls = {},
    },
  },
}
