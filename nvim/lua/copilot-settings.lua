vim.cmd [[
  imap <silent><script><expr> <C-l> copilot#Accept("\<CR>")
  let g:copilot_no_tab_map = v:true
  let g:copilot_filetypes = { 'lua': v:false }
]]
