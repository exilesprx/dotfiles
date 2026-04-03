return {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  lazy = true,
  cmd = "ConformInfo",
  opts = {
    formatters = {
      oxfmt = {
        condition = function(_, ctx)
          return vim.fs.find({ ".oxfmtrc.json", ".oxfmtrc.jsonc" }, { path = ctx.filename, upward = true })[1]
        end,
      },
      prettier = {
        condition = function(_, ctx)
          return vim.fs.find({ ".prettierrc.json" }, { path = ctx.filename, upward = true })[1]
        end,
      },
    },
  },
}
