_G = _G
local vim = _G.vim
local map = vim.api.nvim_set_keymap
local settings = { noremap = true, silent = true }

vim.g.gitblame_enabled = 0

map("n", "<Leader>gb", ":GitBlameToggle<CR>", settings)
map("n", "<Leader>gbo", ":GitBlameOpenCommitURL<CR>", settings)
