return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "black",
        "haskell-language-server",
        "lua-language-server",
        "phpactor",
        "phpcs",
        "php-cs-fixer",
        "prettier",
        "stylua",
        "shellcheck",
        "shfmt",
        "vue-language-server",
      },
    },
  },
}
