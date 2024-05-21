return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "lawrence-laz/neotest-zig",
      "mrcjkb/neotest-haskell",
      "nvim-neotest/neotest-python",
    },
    opts = {
      adapters = {
        "neotest-zig",
        "neotest-haskell",
        ["neotest-python"] = {
          runner = "pytest",
        },
      },
    },
  },
}
