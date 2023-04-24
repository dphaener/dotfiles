return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
  },
  { "tpope/vim-rails" },
  { "tpope/vim-surround" },
  { "tpope/vim-repeat" },
  { "folke/lsp-colors.nvim" },
  {
    "kdheepak/lazygit.nvim",
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
  { "NvChad/nvim-colorizer.lua" },
  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesj").setup({ use_default_keymaps = false })
    end,
  },
  {
    "numToStr/FTerm.nvim",
    keys = {
      { "<leader>;", "<cmd>lua require('FTerm').toggle()<cr>", desc = "Toggle Terminal" },
      { "<leader>;", "<cmd>lua require('FTerm').toggle()<cr>", mode = "t", desc = "Toggle Terminal" },
    },
  },
}
