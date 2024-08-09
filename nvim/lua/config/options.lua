-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

_G = _G
local vim = _G.vim
local opt = vim.opt

opt.mouse = ""
opt.textwidth = 120
opt.colorcolumn = "+1"
opt.pumblend = 0
opt.list = false

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  float = { border = "single" },
})
