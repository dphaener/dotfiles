local util = require("lspconfig").util

return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "css-lsp",
        "erb-lint",
        "html-lsp",
        "lua-language-server",
        "prettier",
      },
    },
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
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim", "Util" },
              },
            },
          },
        },
      },
    },
  },
}
