local telescope = require("telescope")
local map = vim.api.nvim_set_keymap

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous"
      }
    }
  }
})
telescope.load_extension("fzy_native")

map("n", "<Leader>o", ":Telescope find_files<CR>", {noremap = true})
map("n", "<Leader>rg", ":Telescope live_grep<CR>", {noremap = true})
