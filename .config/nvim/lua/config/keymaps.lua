-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local wk = require("which-key")
wk.add({
  { "<leader>z", group = "Lua" }, -- group
  { "<leader>zl", ":.lua<CR>", desc = "Source line", mode = "n" },
  { "<leader>zf", "<cmd>source %<CR>", desc = "Source file", mode = "n" },
})
