require("plugins")
require("apprentice").setup()
require("settings")
require("keyboard-settings")
require("lualine-settings")
require("nerdtree-settings")
require("telescope-settings")
require("lsp-settings")
require("completion-settings")
require("copilot-settings")
require("splitjoin-settings")

vim.o.background = "dark"
vim.g.codeschool_contrast_dark = "hard"

require('lush')(require('codeschool').setup({
  plugins = {
    "cmp",
    "fzf",
    "gitgutter",
    "gitsigns",
    "lsp",
    "nerdtree",
    "packer",
    "telescope",
    "treesitter"
  },
  langs = {
    "css",
    "html",
    "js",
    "json",
    "jsx",
    "lua",
    "markdown",
    "ruby",
    "typescript",
    "viml",
    "xml"
  }
}))
