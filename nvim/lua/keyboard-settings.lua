local map = vim.api.nvim_set_keymap

-- Change the leader to the spacebar
vim.g.mapleader = " "

-- Map s to source the vimrc file
map("n", "<Leader>s", ":source ~/.config/nvim/init.lua<CR>", {noremap = true})

-- Refresh file
map("n", "<Leader>f", ":edit<CR>", {noremap = true})

-- Easily open the config file in a vertical split
map("n", "<Leader>v", ":vsplit ~/.config/nvim/init.lua<CR>" , {noremap = true})

-- Remove all trailing whitespace from the file
map("n", "<Leader>ts", ":%s/\\s\\+$//<CR>", {noremap = true})

-- Fix the indentation in a normal file
map("n", "<Leader>i", "mzgg=G`z", {noremap = true})
