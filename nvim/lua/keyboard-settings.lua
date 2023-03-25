local map = vim.api.nvim_set_keymap
local settings = { noremap = true, silent = true }

-- Change the leader to the spacebar
vim.g.mapleader = " "

-- Refresh file
map("n", "<Leader>f", ":edit<CR>", settings)

-- Easily open the config file in a vertical split
map("n", "<Leader>v", ":vsplit ~/.config/nvim/init.lua<CR>", settings)

-- Remove all trailing whitespace from the file
map("n", "<Leader>rts", ":%s/\\s\\+$//<CR>", settings)

-- Fix the indentation in a normal file
map("n", "<Leader>i", "mzgg=G`z", settings)

map("n", "<Leader>ru", ":Dispatch bundle exec rubocop<CR>", settings)

-- Delete all buffers
map("n", "<Leader>bd", ":%bd!<CR>", settings)

-- Remove the search highlight
map("n", "<Leader>nh", ":noh<CR>", settings)

-- Open the linter diagnostic float
vim.keymap.set("n", "<space>gl", vim.diagnostic.open_float, settings)

map("n", "<Leader>;", ":lua require('FTerm').toggle()<CR>", settings)
map("t", "<Leader>;", "<C-\\><C-n>:lua require('FTerm').toggle()<CR>", settings)
map("n", "<Leader>bp", "obinding.pry<ESC>", settings)
map("n", "<Leader>bP", "Obinding.pry<ESC>", settings)
map("n", "<Leader>p", "maggo rubocop:disable Rails/Output<ESC>`azz", settings)
