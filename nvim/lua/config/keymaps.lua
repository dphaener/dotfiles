-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.api.nvim_set_keymap

map("n", "<Leader>rts", ":%s/\\s\\+$//<CR>", { noremap = true, silent = true, desc = "Remove trailing whitespace" })
map("n", "<Leader>i", "mzgg=G`z", { noremap = true, silent = true, desc = "Fix the indentation in a normal file" })
map("n", "<Leader>nh", ":noh<CR>", { noremap = true, silent = true, desc = "Remove the search highlight" })
map("n", "<Leader>bp", "obinding.pry<ESC>", { noremap = true, silent = true, desc = "Insert binding.pry below" })
map("n", "<Leader>bP", "Obinding.pry<ESC>", { noremap = true, silent = true, desc = "Insert binding.pry above" })
map(
  "t",
  "<Leader>td",
  "<C-\\><C-n>:q<CR>",
  { noremap = true, silent = true, desc = "Detach from the current test terminal" }
)
map(
  "n",
  "<Leader>p",
  "maggo rubocop:disable Rails/Output<ESC>`azz",
  { noremap = true, silent = true, desc = "Insert rubocop:disable Rails/Output" }
)
map(
  "n",
  "<Leader>s",
  "<cmd>lua require('neotest').run.run({ env = { RAILS_ENV = 'test' } })<cr>",
  { noremap = true, silent = true, desc = "Run the nearest spec" }
)
map(
  "n",
  "<Leader>t",
  "<cmd>lua require('neotest').run.run({ vim.fn.expand('%'), env = { RAILS_ENV = 'test' } })<cr>",
  { noremap = true, silent = true, desc = "Run all tests for the current buffer" }
)
map(
  "n",
  "<Leader>sbr",
  "<cmd>lua require('neotest').run.run({ env = { RAILS_ENV = 'test', USE_BROWSER = 'true' } })<cr>",
  { noremap = true, silent = true, desc = "Run the current feature spec using the browser" }
)
map(
  "n",
  "<Leader>a",
  "<cmd>lua require('neotest').run.run({ vim.fn.getcwd(), env = { RAILS_ENV = 'test' } })<cr>",
  { noremap = true, silent = true, desc = "Run all tests" }
)
map(
  "n",
  "<Leader>to",
  "<cmd>lua require('neotest').output.open({ enter = true })<cr>",
  { noremap = true, silent = true, desc = "View the test output" }
)
map(
  "n",
  "<Leader>ts",
  "<cmd>lua require('neotest').summary.toggle()<cr>",
  { noremap = true, silent = true, desc = "Toggle the test summary panel" }
)
map(
  "n",
  "<Leader>ta",
  "<cmd>lua require('neotest').run.attach()<cr>",
  { noremap = true, silent = true, desc = "Attach to the currently running test" }
)
map(
  "n",
  "<Leader>cst",
  "<cmd>lua require('treesj').toggle()<cr>",
  { noremap = true, silent = true, desc = "Toggle the current split" }
)
map(
  "n",
  "<Leader>css",
  "<cmd>lua require('treesj').split()<cr>",
  { noremap = true, silent = true, desc = "Split the current code block" }
)
map(
  "n",
  "<Leader>csj",
  "<cmd>lua require('treesj').join()<cr>",
  { noremap = true, silent = true, desc = "Join the current code block" }
)
