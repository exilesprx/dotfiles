return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
      },
      sources = {
        per_filetype = {
          opencode_ask = { "lsp", "buffer" },
        },
        providers = {
          lsp = {
            fallback = {},
          },
        },
      },
    },
  },
}
