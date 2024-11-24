local util = require("lspconfig").util

return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "css-lsp",
        "erb-lint",
        "eslint-lsp",
        "eslint_d",
        "html-lsp",
        "lua-language-server",
        "prettier",
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {
          cmd = { "/Users/darinhaener/.asdf/shims/ruby-lsp" },
        },
        rubocop = {
          cmd = { "bundle", "exec", "rubocop", "--lsp" },
          root_dir = util.root_pattern("Gemfile", ".git"),
        },
      },
    },
  },
}
