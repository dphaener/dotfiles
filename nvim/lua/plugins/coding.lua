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
      copilot_node_command = "/Users/darinhaener/.asdf/installs/nodejs/20.9.0/bin/node",
    },
  },
}
