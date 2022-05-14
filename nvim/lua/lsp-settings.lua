local config = require("lspconfig")

require("utils.lsp").install_servers{
  "cssls",
  "eslint",
  "html",
  "jsonls",
  "solargraph",
  "tailwindcss",
  "tsserver",
}

config.cssls.setup{}
config.eslint.setup{}
config.html.setup{}
config.jsonls.setup{}
config.solargraph.setup{
  settings = {
    solargraph = {
      autoformat = true,
      formatting = true,
      diagnostics = true,
      hover = true,
      completion = true,
    }
  }
}
config.tailwindcss.setup{}
config.tsserver.setup{}
