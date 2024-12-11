-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>zl", ":.lua<CR>", { desc = "Source line" })
vim.keymap.set("n", "<leader>zf", "<cmd>source %<CR>", { desc = "Source file" })
print("Keymaps loaded")
