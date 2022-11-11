_G = _G
local vim = _G.vim
local set = vim.opt

vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1
vim.api.nvim_create_autocmd({ "CursorHold", "FileChangedShell", "FocusGained" }, {
  command = "checktime",
  pattern = { "*" },
})
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  command = "silent! lua vim.lsp.buf.format({ async = true })",
  pattern = { "*" },
})
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  command = "set relativenumber",
  pattern = { "*" },
})
vim.cmd("colorscheme nightfox")
vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")

vim.o.number = true
vim.o.termguicolors = true
vim.o.autoread = true

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
