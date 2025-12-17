-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Set inline completion ghost text colors (ComplHint and ComplHintMore)
local ghost_color = "#7f849c" -- Subtle gray for better visibility

vim.api.nvim_set_hl(0, "ComplHint", {
  fg = ghost_color,
  italic = true,
})

vim.api.nvim_set_hl(0, "ComplHintMore", {
  fg = ghost_color,
  italic = true,
})

-- Reapply after colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "ComplHint", {
      fg = ghost_color,
      italic = true,
    })
    vim.api.nvim_set_hl(0, "ComplHintMore", {
      fg = ghost_color,
      italic = true,
    })
  end,
})
