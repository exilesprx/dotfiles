return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.theme = "palenight"
      opts.sections = opts.sections or {}
      opts.sections.lualine_z = vim.list_extend(opts.sections.lualine_z or {}, {
        { require("opencode").statusline },
      })
    end,
  },
}
