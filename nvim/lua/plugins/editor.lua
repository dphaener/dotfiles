return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        config = function()
          require("telescope").load_extension("fzf")
        end,
      },
      {
        "princejoogie/dir-telescope.nvim",
        config = function()
          require("dir-telescope").setup()
        end,
      },
      { "nvim-telescope/telescope-file-browser.nvim" },
    },
    keys = {
      { "<leader>fl", "<cmd>Telescope file_browser<cr>", desc = "File Browser" },
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          i = {
            ["<CR>"] = function(prompt_bufnr)
              require("telescope_extensions").multi_open(prompt_bufnr, "default")
            end,
            ["<C-V>"] = function(prompt_bufnr)
              require("telescope_extensions").multi_open(prompt_bufnr, "vertical")
            end,
          },
        },
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>ch", group = "highlight" },
        { "<leader>gh", group = "hunks" },
        { "<leader>i", group = "insert" },
        { "<leader>r", group = "rails", icon = { icon = "󰫏", color = "red" } },
        { "<leader>z", group = "zettelkasten" },
      },
    },
  },
  { "tpope/vim-rails" },
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
    keys = {
      {
        "<leader>cst",
        "<cmd>lua require('treesj').toggle()<cr>",
        desc = "Toggle the current split",
      },
      {
        "<leader>css",
        "<cmd>lua require('treesj').split()<cr>",
        desc = "Split the current code block",
      },
      {
        "<leader>csj",
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
  { "mustache/vim-mustache-handlebars" },
}
