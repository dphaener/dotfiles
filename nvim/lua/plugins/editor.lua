return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>ch", group = "highlight" },
        { "<leader>gh", group = "hunks" },
        { "<leader>i", group = "insert" },
        { "<leader>r", group = "rails", icon = { icon = "󰫏", color = "red" } },
        { "<leader>ct", group = "treesj" },
      },
    },
  },
  { "tpope/vim-rails" },
  { "NvChad/nvim-colorizer.lua" },
  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesj").setup({ use_default_keymaps = false })
    end,
    keys = {
      {
        "<leader>ctt",
        "<cmd>lua require('treesj').toggle()<cr>",
        desc = "Toggle the current split",
      },
      {
        "<leader>cts",
        "<cmd>lua require('treesj').split()<cr>",
        desc = "Split the current code block",
      },
      {
        "<leader>ctj",
        "<cmd>lua require('treesj').join()<cr>",
        desc = "Join the current code block",
      },
    },
  },
  {
    "numToStr/FTerm.nvim",
    keys = {
      { "<leader>;", "<cmd>lua require('FTerm').toggle()<cr>", desc = "Toggle Terminal" },
      { "<leader>;", "<cmd>lua require('FTerm').toggle()<cr>", mode = "t", desc = "Toggle Terminal" },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        auto_close = true,
      },
    },
  },
}
