return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "RRethy/nvim-treesitter-endwise" },
    opts = {
      endwise = { enable = true },
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "python",
        "query",
        "regex",
        "ruby",
        "tsx",
        "vim",
        "yaml",
      },
    },
  },
}
