set nocompatible
set encoding=UTF-8

call plug#begin(stdpath('data') . '/plugged')

Plug 'blueshirts/darcula'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'itchyny/lightline.vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 'junegunn/fzf'
Plug 'vimlab/split-term.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mxw/vim-jsx'
Plug 'miki725/vim-ripgrep'
Plug 'peitalin/vim-jsx-typescript'
Plug 'ryanoasis/vim-devicons'
Plug 'ianks/vim-tsx'
Plug 'tpope/vim-rails'

call plug#end()

function! s:SourceFile(filename)
  execute "source ~/.config/nvim/" . a:filename
endfunction

call s:SourceFile("settings.vim")
call s:SourceFile("keyboard-settings.vim")
call s:SourceFile("lightline.vim")
call s:SourceFile("fugitive.vim")
call s:SourceFile("nerdtree.vim")
call s:SourceFile("coc.vim")
call s:SourceFile("ctrlp.vim")
