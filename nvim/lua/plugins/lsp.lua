return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "css-lsp",
        "erb-lint",
        "eslint-lsp",
        "eslint_d",
        "gitlint",
        "html-lsp",
        "jq",
        "json-lsp",
        "jsonlint",
        "lemminx",
        "lua-language-server",
        "markdownlint",
        "prettier",
        "shellcheck",
        "shfmt",
        "solargraph",
        "sql-formatter",
        "sqlls",
        "stylua",
        "tailwindcss-language-server",
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
}
