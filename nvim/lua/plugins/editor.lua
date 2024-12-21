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
    "nvim-neo-tree/neo-tree.nvim",
    config = function(_, opts)
      local function on_move(data)
        Util.lsp.on_rename(data.source, data.destination)
      end
      local events = require("neo-tree.events")
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
        {
          event = "file_opened",
          handler = function(_)
            require("neo-tree.command").execute({ action = "close" })
          end,
        },
      })
      require("neo-tree").setup(opts)
      vim.api.nvim_create_autocmd("TermClose", {
        pattern = "*lazygit",
        callback = function()
          if package.loaded["neo-tree.sources.git_status"] then
            require("neo-tree.sources.git_status").refresh()
          end
        end,
      })
    end,
  },
}
