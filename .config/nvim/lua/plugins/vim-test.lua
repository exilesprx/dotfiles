return {
  "vim-test/vim-test",
  dependencies = { "preservim/vimux" },
  init = function()
    vim.cmd("let test#strategy = 'vimux'")
  end,
}
