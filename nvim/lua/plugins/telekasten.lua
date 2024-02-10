local home = vim.fn.expand("~/Nextcloud/zettelkasten")

return {
  "renerocksai/telekasten.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "renerocksai/calendar-vim",
    "nvim-telescope/telescope-media-files.nvim",
  },
  keys = {
    {
      "<leader>zn",
      "<cmd>Telekasten new_note<cr>",
      desc = "New note",
    },
    {
      "<leader>zp",
      "<cmd>Telekasten panel<cr>",
      desc = "Open Telekasten panel",
    },
    {
      "<leader>zf",
      "<cmd>Telekasten find_notes<cr>",
      desc = "Find note",
    },
    {
      "<leader>zg",
      "<cmd>Telekasten search_notes<cr>",
      desc = "Search notes",
    },
    {
      "<leader>zb",
      "<cmd>Telekasten show_backlinks<cr>",
      desc = "Show backlinks",
    },
    {
      "<leader>zl",
      "<cmd>Telekasten follow_link<cr>",
      desc = "Follow link",
    },
  },
  config = function()
    require("telescope").load_extension("media_files")
    require("telekasten").setup({
      home = home,
      template_new_note = home .. "/" .. "templates/new_note.md",
    })
  end,
}
