local max_width_percentage = 0.9
local max_height_percentage = 0.9
local width = vim.api.nvim_win_get_width(0)
local height = vim.api.nvim_win_get_height(0)
local max_column_width = math.floor(width * max_width_percentage)
local max_row_height = math.floor(height * max_height_percentage)

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
      "olimorris/neotest-rspec",
    },
    keys = {
      {
        "<leader>tp",
        "<cmd>lua require('neotest').jump.prev({ status = 'failed' })<CR>",
        desc = "Jump to the previous failed test",
      },
      {
        "<leader>tn",
        "<cmd>lua require('neotest').jump.next({ status = 'failed' })<CR>",
        desc = "Jump to the next failed test",
      },
      {
        "<leader>to",
        "<cmd>lua require('neotest').output.open({ enter = true })<CR>",
        desc = "View the test output",
      },
      {
        "<leader>ta",
        "<cmd>lua require('neotest').run.attach()<CR>",
        desc = "Attach to the currently running test",
      },
      {
        "<leader>td",
        "<C-\\><C-n>:q<CR>",
        desc = "Detach from the current test terminal",
        mode = { "t" },
      },
    },
    opts = {
      adapters = {
        "neotest-rspec",
        ["neotest-vitest"] = {},
      },
      floating = {
        max_width = max_width_percentage,
        max_height = max_height_percentage,
      },
      strategies = {
        integrated = {
          height = max_row_height,
          width = max_column_width,
        },
      },
      status = { virtual_text = false },
      quickfix = {
        enabled = false,
        open = false,
      },
    },
  },
}
