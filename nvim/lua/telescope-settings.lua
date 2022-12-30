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
telescope.load_extension("dap")

map("n", "<Leader>o", ":Telescope find_files<CR>", { noremap = true })
map("n", "<Leader>rg", ":Telescope live_grep<CR>", { noremap = true })
map("n", "<Leader>b", ":Telescope buffers<CR>", { noremap = true })
map("n", "<Leader>gc", ":Telescope git_commits<CR>", { noremap = true })
map("n", "<Leader>gs", ":Telescope git_status<CR>", { noremap = true })
map("n", "<Leader>ts", ":Telescope treesitter<CR>", { noremap = true })
map("n", "<Leader>td", ":Telescope dap commands<CR>", { noremap = true })
-- :Telescope dap configurations
-- :Telescope dap list_breakpoints
-- :Telescope dap variables
-- :Telescope dap frames
