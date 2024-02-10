-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.api.nvim_set_keymap

map("n", "<Leader>ip", "obinding.pry<ESC>", { noremap = true, silent = true, desc = "Insert binding.pry below" })
map("n", "<Leader>iP", "Obinding.pry<ESC>", { noremap = true, silent = true, desc = "Insert binding.pry above" })
map(
  "n",
  "<Leader>p",
  "maggo rubocop:disable Rails/Output<ESC>`azz",
  { noremap = true, silent = true, desc = "Insert rubocop:disable Rails/Output" }
)
