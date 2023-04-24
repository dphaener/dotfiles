local max_width_percentage = 0.9
local max_height_percentage = 0.9
local width = vim.api.nvim_win_get_width(0)
local height = vim.api.nvim_win_get_height(0)
local max_column_width = math.floor(width * max_width_percentage)
local max_row_height = math.floor(height * max_height_percentage)

return {
  { "olimorris/neotest-rspec" },
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        "neotest-rspec",
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
