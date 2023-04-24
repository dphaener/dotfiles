return {
  {
    "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })
      require("luasnip").filetype_extend("ruby", { "rails" })
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = { enabled = true },
      panel = { enabled = true },
      filetypes = {
        ["*"] = true,
      },
    },
  },
}
