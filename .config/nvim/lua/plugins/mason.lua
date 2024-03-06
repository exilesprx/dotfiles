return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "haskell-language-server",
        "lua-language-server",
        "phpactor",
        "python-lsp-server",
        "stylua",
        "shellcheck",
        "shfmt",
        "zls",
      },
    },
  },
}
