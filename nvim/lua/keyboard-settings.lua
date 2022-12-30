local map = vim.api.nvim_set_keymap
local settings = { noremap = true, silent = true }

-- Change the leader to the spacebar
vim.g.mapleader = " "

-- Refresh file
map("n", "<Leader>f", ":edit<CR>", { noremap = true, silent = true })

-- Easily open the config file in a vertical split
map("n", "<Leader>v", ":vsplit ~/.config/nvim/init.lua<CR>", { noremap = true, silent = true })

-- Remove all trailing whitespace from the file
map("n", "<Leader>rts", ":%s/\\s\\+$//<CR>", { noremap = true, silent = true })

-- Fix the indentation in a normal file
map("n", "<Leader>i", "mzgg=G`z", { noremap = true, silent = true })

map("n", "<Leader>ru", ":Dispatch bundle exec rubocop<CR>", { noremap = true, silent = true })

-- Delete all buffers
map("n", "<Leader>bd", ":%bd!<CR>", { noremap = true, silent = true })

-- Remove the search highlight
map("n", "<Leader>nh", ":noh<CR>", { noremap = true, silent = true })

-- Extract variable declaration to a method
map("n", "<Leader>r", ":ExtractMethod<CR>", { noremap = true, silent = true })

map("n", "<Leader>;", ":lua require('FTerm').toggle()<CR>", { noremap = true, silent = true })
map("t", "<Leader>;", "<C-\\><C-n>:lua require('FTerm').toggle()<CR>", { noremap = true, silent = true })
