set relativenumber
set number

call plug#begin()

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.2' }
Plug 'navarasu/onedark.nvim'

call plug#end()

lua require('init')
