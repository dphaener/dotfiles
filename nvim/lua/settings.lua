local set = vim.opt

vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = { "*" },
})
vim.o.number = true
vim.o.termguicolors = true

set.encoding = "UTF-8"
set.tabstop = 2
set.shiftwidth = 2
set.expandtab = true
set.tags = "./tags"
set.laststatus = 2
set.wildignore = set.wildignore + "*.so,*.swp,*.zip,*/node_modules/*"
set.wrap = false
set.textwidth = 120
set.colorcolumn = "+1"
set.autoread = true
set.mouse = ""

vim.cmd [[
  syntax enable
  filetype plugin indent on
  colorscheme tokyonight-night
  autocmd BufEnter * set relativenumber
  autocmd BufWritePre * lua vim.lsp.buf.formatting()
]]
-- autocmd BufWritePre *.js EslintFixAll
