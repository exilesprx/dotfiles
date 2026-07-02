return {
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = true },
      cli = {
        mux = {
          enabled = true,
          backend = "zellij",
        },
      },
    },
  },
}
