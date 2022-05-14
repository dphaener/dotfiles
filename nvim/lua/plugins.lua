-- Install packer
local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

vim.cmd [[
  augroup Packer
    autocmd!
    autocmd BufWritePost plugins.lua PackerCompile
  augroup end
]]

return require("packer").startup(function()
  use "wbthomason/packer.nvim"
  use "blueshirts/darcula"
  use {
    "scrooloose/nerdtree",
    requires = {
      "Xuyuanp/nerdtree-git-plugin",
      "ryanoasis/vim-devicons"
    }
  }
  use {
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true }
  }
  use {
    "nvim-telescope/telescope.nvim",
    requires = { "nvim-lua/plenary.nvim" }
  }
  use "nvim-telescope/telescope-fzy-native.nvim"
  use "tpope/vim-fugitive"
  use "tpope/vim-surround"
  use "tpope/vim-repeat"
  use "ntpeters/vim-better-whitespace"
  use "tpope/vim-rails"
  use "ms-jpq/lua-async-await"
  use "neovim/nvim-lspconfig"
  use "hrsh7th/nvim-cmp" -- Autocompletion plugin
  use "hrsh7th/cmp-nvim-lsp" -- LSP source for nvim-cmp
  use "saadparwaiz1/cmp_luasnip" -- Snippets source for nvim-cmp
  use "L3MON4D3/LuaSnip" -- Snippets plugin
  use "github/copilot.vim"
  use "tpope/vim-endwise"
  use "nvim-lua/popup.nvim"
  use "AndrewRadev/splitjoin.vim"
end)
