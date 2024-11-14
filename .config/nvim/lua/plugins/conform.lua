return {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  lazy = true,
  cmd = "ConformInfo",
  opts = {
    ---@type table<string, conform.FormatterUnit[]>
    formatters_by_ft = {
      ["bash"] = { "shellcheck" },
      ["css"] = { "prettier" },
      ["html"] = { "prettier" },
      ["javascript"] = { "prettier" },
      ["json"] = { "prettier" },
      ["lua"] = { "stylua" },
      ["markdown"] = { "prettier" },
      ["php"] = { "php_cs_fixer" },
      ["typescript"] = { "prettier" },
      ["sh"] = { "shfmt" },
      ["vue"] = { "prettier" },
      ["yaml"] = { "prettier" },
    },
  },
}
