return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.theme = "palenight"
      opts.sections = opts.sections or {}
      opts.sections.lualine_z = opts.sections.lualine_z or {}
      table.insert(opts.sections.lualine_z, {
        require("opencode").statusline,
      })
    end,
  },
}
