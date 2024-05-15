return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
    },
    init = function()
      local lspconfig = require("lspconfig")
      lspconfig.zls.setup({
        type = "zls",
        cmd = { "zls" },
      })
    end,
  },
}
