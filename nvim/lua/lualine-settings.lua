require("lualine").setup({
  options = {
    theme = "tokyonight",
  },
  sections = { lualine_c = { require("auto-session-library").current_session_name } }
})
