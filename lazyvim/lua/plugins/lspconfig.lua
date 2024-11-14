return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      bashls = {},
      ruff = {
        settings = {
          args = {
            "--line-length=120",
          },
        },
      },
      eslint = {
        settings = {
          packageManager = "yarn",
        },
      },
    },
  },
}
