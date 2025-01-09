return {
  {
    "folke/which-key.nvim",
    opts = {
      preset = "classic",
      spec = {
        { "<leader>z", group = "Lua" },
        { "<leader>zl", ":.lua<CR>", desc = "Source line", mode = "n" },
        { "<leader>zf", "<cmd>source %<CR>", desc = "Source file", mode = "n" },
        { "<leader>e", "<cmd>Oil<CR>", desc = "Open current directory", mode = "n" },
      },
    },
  },
}
