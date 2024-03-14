return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "haskell-language-server",
        "lua-language-server",
        "phpactor",
        "php-cs-fixer",
        "python-lsp-server",
        "stylua",
        "shellcheck",
        "shfmt",
        "vue-language-server",
        "zls",
      },
    },
  },
}
