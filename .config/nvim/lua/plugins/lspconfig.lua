return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
    },
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.zls.setup({
        cmd = { "zls" },
      })
    end,
  },
}
