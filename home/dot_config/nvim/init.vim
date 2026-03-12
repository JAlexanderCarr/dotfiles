" ------------------------------------
" Plugin Setup
" ------------------------------------

call plug#begin(stdpath('data') . '/plugged')

" Theme
Plug 'projekt0n/github-nvim-theme'

" Status Line
Plug 'nvim-lualine/lualine.nvim'

" File Management
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'

" Git Integration
Plug 'lewis6991/gitsigns.nvim'

" Keybindings Helper
Plug 'folke/which-key.nvim'

" Formatting
Plug 'tpope/vim-surround.nvim'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'

" Autocompletion
Plug 'hrsh7th/nvim-cmp'          " Completion engine
Plug 'hrsh7th/cmp-nvim-lsp'      " LSP completion source
Plug 'hrsh7th/cmp-buffer'        " Buffer word completion source
Plug 'hrsh7th/cmp-path'          " File path completion source

call plug#end()

" GitHub Dark Theme Configuration
set background=dark
colorscheme github_dark_default

" ------------------------------------
" General Settings
" ------------------------------------

" Use system clipboard via OSC 52 (works over SSH, in containers, and on macOS)
set clipboard=unnamedplus
lua << EOF
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}
EOF

" Hide bottom bar
set noshowmode

" Enable true color support
set termguicolors

" Enable syntax highlighting
syntax enable

" Show line numbers
set number

" Enable filetype detection, plugins, and indentation
filetype plugin indent on

" Show guide column at 80 chars
set colorcolumn=80

" Enforce 80-char textwidth for all filetypes — overrides built-in ftplugins
autocmd FileType * setlocal textwidth=80
