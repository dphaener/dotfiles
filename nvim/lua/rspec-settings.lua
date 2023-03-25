local map = vim.api.nvim_set_keymap
local max_width_percentage = 0.9
local max_height_percentage = 0.9
local width = vim.api.nvim_get_option("columns")
local height = vim.api.nvim_get_option("lines")
local max_column_width = math.floor(width * max_width_percentage)
local max_row_height = math.floor(height * max_height_percentage)

require("neotest").setup({
  adapters = {
    require("neotest-rspec")({
      rspec_cmd = function()
        return vim.tbl_flatten({
          "bundle",
          "exec",
          "rspec",
        })
      end
    }),
  },
  floating = {
    max_width = max_width_percentage,
    max_height = max_height_percentage,
  },
  strategies = {
    integrated = {
      height = max_row_height,
      width = max_column_width,
    }
  },
  quickfix = {
    enabled = false,
    open = false,
  },
})

map("n", "<Leader>t",
  ":lua require('neotest').run.run({ vim.fn.expand('%'), env = { RUN_FEATURE_SPECS = 'true' } })<CR>"
  , { noremap = true, silent = true })
map("n", "<Leader>s", ":lua require('neotest').run.run({ env = { RUN_FEATURE_SPECS = 'true' } })<CR>",
  { noremap = true, silent = true })
map("n", "<Leader>sb",
  ":lua require('neotest').run.run({ env = { RUN_FEATURE_SPECS = 'true', USE_BROWSER = 'true' } })<CR>",
  { noremap = true, silent = true })
map("n", "<Leader>a", ":lua require('neotest').run.run({ vim.fn.getcwd(), env = { RUN_FEATURE_SPECS = 'true' } })<CR>",
  { noremap = true, silent = true })
map("n", "<Leader>to", ":lua require('neotest').output.open({ enter = true })<CR>", { noremap = true, silent = true })
map("n", "<Leader>ts", ":lua require('neotest').summary.toggle()<CR>", { noremap = true, silent = true })
map("n", "<Leader>ta", ":lua require('neotest').run.attach()<CR>", { noremap = true, silent = true })
map("t", "<Leader>td", "<C-\\><C-n>:q<CR>", { noremap = true, silent = true })
map("n", "[n", ":lua require('neotest').jump.prev({ status = 'failed' })<CR>", { noremap = true, silent = true })
map("n", "]n", ":lua require('neotest').jump.next({ status = 'failed' })<CR>", { noremap = true, silent = true })
