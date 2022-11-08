local map = vim.api.nvim_set_keymap

vim.g.rspec_command = "Dispatch RUN_FEATURE_SPECS=true bundle exec spring rspec {spec}"

map("n", "<Leader>t", ":call RunCurrentSpecFile()<CR>", { noremap = true })
map("n", "<Leader>s", ":call RunNearestSpec()<CR>", { noremap = true })
map("n", "<Leader>l", ":call RunLastSpec()<CR>", { noremap = true })
map("n", "<Leader>a", ":call RunAllSpecs()<CR>", { noremap = true })
