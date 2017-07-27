" Specify a directory for plugins
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'easymotion/vim-easymotion'
Plug 'sjl/badwolf'
Plug 'vim-airline/vim-airline'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }

" On-demand loading
" Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

" Initialize plugin system
call plug#end()

&runtimepath
set laststatus=2

set number
syntax enable
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

set t_Co=256

" vim-airline settings
let g:airline_powerline_fonts = 1

" vim-indent-guides plugin settings
let g:indent_guides_guide_size = 1
let g:indent_guides_color_change_percent = 3
let g:indent_guides_enable_on_vim_startup = 1
