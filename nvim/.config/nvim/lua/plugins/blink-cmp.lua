return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.per_filetype = vim.tbl_deep_extend("force", opts.sources.per_filetype or {}, {
        opencode_ask = { "lsp", "buffer" },
      })
    end,
  },
}
