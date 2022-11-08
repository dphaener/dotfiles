local lsp = require("lsp-zero")
local cmp = require("cmp")
local lspkind = require("lspkind")

lsp.preset("recommended")
lsp.setup_nvim_cmp({
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = false
    }),
  }),
  sources = {
    { name = "path" },
    { name = "nvim_lsp", keyword_length = 3 },
    { name = "luasnip", keyword_length = 3 },
    { name = "copilot" },
    { name = "treesitter" },
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol",
      max_width = 50,
      symbol_map = { Copilot = "" }
    })
  }
})
lsp.ensure_installed({
  "html",
  "cssls",
  "tsserver",
  "eslint",
  "solargraph"
})
lsp.setup()
