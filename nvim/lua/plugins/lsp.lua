return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "css-lsp",
        "erb-lint",
        "eslint-lsp",
        "eslint_d",
        "flake8",
        "gitlint",
        "grammarly-languageserver",
        "html-lsp",
        "jq",
        "json-lsp",
        "jsonlint",
        "lemminx",
        "ltex-ls",
        "lua-language-server",
        "prettier",
        "pyright",
        "rubocop",
        "shellcheck",
        "shfmt",
        "solargraph",
        "sql-formatter",
        "sqlls",
        "stylua",
        "tailwindcss-language-server",
        "typescript-language-server",
        "vim-language-server",
        "yaml-language-server",
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "emoji" } }))
      opts.window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      }
      opts.mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        }),
      })
      opts.experimental.ghost_text = false
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = {
        html = {},
        cssls = {},
        eslint = {},
        solargraph = {},
        lua_ls = {},
      }
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason.nvim" },
    opts = function()
      local nls = require("null-ls")
      return {
        root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
        sources = {
          nls.builtins.formatting.stylua,
          nls.builtins.formatting.prettierd,
          nls.builtins.formatting.jq,
          nls.builtins.formatting.remark,
          nls.builtins.formatting.eslint_d,
        },
      }
    end,
  },
}
