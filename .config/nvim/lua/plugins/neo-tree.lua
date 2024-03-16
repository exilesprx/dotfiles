return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
        },
      },
      popup_border_style = "rounded",
      window = {
        position = "float",
      },
    },
  },
}
