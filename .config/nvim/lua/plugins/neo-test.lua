return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "lawrence-laz/neotest-zig",
    },
    opts = {
      adapters = {
        "neotest-zig",
        ["neotest-python"] = {
          runner = "pytest",
        },
      },
    },
  },
}
