local map = vim.api.nvim_set_keymap

require("neotest").setup({
  adapters = {
    require("neotest-rspec")({
      rspec_cmd = function()
        return vim.tbl_flatten({
          "bundle",
          "exec",
          "spring",
          "rspec",
        })
      end
    }),
  },
  floating = {
    max_width = 0.9,
    max_height = 0.9,
  },
})

map("n", "<Leader>t",
  ":lua require('neotest').run.run({ vim.fn.expand('%'), env = { RUN_FEATURE_SPECS = 'true' } })<CR>"
  , { noremap = true, silent = true })
map("n", "<Leader>s", ":lua require('neotest').run.run({ env = { RUN_FEATURE_SPECS = 'true' } })<CR>",
  { noremap = true, silent = true })
map("n", "<Leader>a", ":lua require('neotest').run.run({ vim.fn.getcwd(), env = { RUN_FEATURE_SPECS = 'true' } })<CR>",
  { noremap = true, silent = true })
map("n", "<Leader>to", ":lua require('neotest').output.open({ enter = true })<CR>", { noremap = true, silent = true })
map("n", "<Leader>ts", ":lua require('neotest').summary.toggle()<CR>", { noremap = true, silent = true })
map("n", "<Leader>ta", ":lua require('neotest').run.attach()<CR>", { noremap = true, silent = true })
map("t", "<Leader>td", "<C-\\><C-n>:q<CR>", { noremap = true, silent = true })
map("n", "[n", ":lua require('neotest').jump.prev({ status = 'failed' })<CR>", { noremap = true, silent = true })
map("n", "]n", ":lua require('neotest').jump.next({ status = 'failed' })<CR>", { noremap = true, silent = true })
