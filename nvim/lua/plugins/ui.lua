local highlight = { "Whitespace" }

return {
  "lukas-reineke/indent-blankline.nvim",
  event = "LazyFile",
  opts = {
    indent = { highlight = highlight, char = "" },
    whitespace = {
      highlight = highlight,
    },
    scope = { enabled = false },
  },
}
