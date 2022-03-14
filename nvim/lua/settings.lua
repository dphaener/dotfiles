local set = vim.opt

set.encoding = "UTF-8"
set.tabstop = 2
set.shiftwidth = 2
set.expandtab = true
set.tags = "./tags"
set.laststatus = 2
set.wildignore = set.wildignore + "*.so,*.swp,*.zip,*/node_modules/*"
set.wrap = false
set.textwidth = 80
set.colorcolumn = "+1"
set.autoread = true

vim.cmd [[
  syntax enable
  filetype plugin indent on
  set number
  colorscheme darcula
  autocmd BufEnter * set relativenumber
  autocmd BufWritePre * lua vim.lsp.buf.formatting()
  autocmd BufWritePre *.js EslintFixAll
]]
