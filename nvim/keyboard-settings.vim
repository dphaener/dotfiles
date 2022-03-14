" Change the leader to the spacebar
let mapleader = "\<Space>"

" Split the current line at the cursor
nnoremap <Leader>k i<CR><Esc>

" Replace hash rockets with new syntax
nmap <leader>rh :%s/\v:(\w+) \=\>/\1:/g<cr>

" Map s to source the vimrc file
map <Leader>s :source ~/.vimrc<CR>

" Refresh file
map <Leader>f :edit<CR>

" Easily open the .vimrc file in a vertical split
map <Leader>v :vsplit ~/.vimrc<CR>

" Remove all trailing whitespace from the file
map <Leader>ts :%s/\s\+$//<CR>

" Open the explorer
map <Leader>e :NERDTreeToggle<CR>

" Fix the indentation in a normal file
map <Leader>i mzgg=G`z

" Add a frozen string literal to the top of the file
map <Leader>fs ggO# frozen_string_literal: true<CR><Esc>x<Esc>
