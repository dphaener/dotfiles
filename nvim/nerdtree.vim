let NERDTreeShowLineNumbers=1
let NERDTreeQuitOnOpen=1
let NERDTreeAutoDeleteBuffer=1
let NERDTreeMinimalUI=1
let NERDTreeDirArrows=1
let NERDTreeWinSize=50

" NERDTrees File highlighting only the glyph/icon
" test highlight just the glyph (icons) in nerdtree:
autocmd filetype nerdtree highlight haskell_icon ctermbg=none ctermfg=Magenta
autocmd filetype nerdtree highlight html_icon ctermbg=none ctermfg=Magenta
autocmd filetype nerdtree highlight go_icon ctermbg=none ctermfg=Blue
autocmd filetype nerdtree highlight rb_icon ctermbg=none ctermfg=Red
autocmd filetype nerdtree highlight heroku_icon ctermbg=none ctermfg=Magenta
autocmd filetype nerdtree highlight js_icon ctermbg=none ctermfg=Yellow
autocmd filetype nerdtree highlight node_icon ctermbg=none ctermfg=Green
autocmd filetype nerdtree highlight hbs_icon ctermbg=none ctermfg=DarkYellow

" if you are using another syn highlight for a given line (e.g.
" NERDTreeHighlightFile) need to give that name in the 'containedin' for this
" other highlight to work with it
autocmd filetype nerdtree syn match haskell_icon ## containedin=NERDTreeFlags
autocmd filetype nerdtree syn match html_icon ## containedin=NERDTreeFlags,html
autocmd filetype nerdtree syn match go_icon ## containedin=NERDTreeFlags
autocmd filetype nerdtree syn match rb_icon ## containedin=NERDTreeFlags
autocmd filetype nerdtree syn match heroku_icon ## containedin=NERDTreeFlags
autocmd filetype nerdtree syn match js_icon ## containedin=NERDTreeFlags
autocmd filetype nerdtree syn match node_icon ## containedin=NERDTreeFlags
autocmd filetype nerdtree syn match hbs_icon ## containedin=NERDTreeFlags
