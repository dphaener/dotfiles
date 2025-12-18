local util = require("lspconfig").util

-- Get Node.js path from global ~/.tool-versions for copilot
local function get_global_nodejs_path()
  local home = vim.fn.expand("~")
  local tool_versions = home .. "/.tool-versions"

  local file = io.open(tool_versions, "r")
  if not file then
    return nil
  end

  for line in file:lines() do
    local version = line:match("^nodejs%s+(.+)$")
    if version then
      file:close()
      return home .. "/.asdf/installs/nodejs/" .. version .. "/bin"
    end
  end

  file:close()
  return nil
end

return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "css-lsp",
        "erb-lint",
        "html-lsp",
        "lua-language-server",
        "prettier",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {
          cmd = { "/Users/darinhaener/.asdf/shims/ruby-lsp" },
        },
        rubocop = {
          cmd = { "bundle", "exec", "rubocop", "--lsp" },
          root_dir = util.root_pattern("Gemfile", ".git"),
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim", "Util" },
              },
            },
          },
        },
        copilot = {
          cmd = {
            vim.fn.expand("~/.local/share/nvim/mason/bin/copilot-language-server"),
            "--stdio",
          },
          cmd_env = {
            -- Override PATH to use Node.js from ~/.tool-versions instead of repo's Node.js
            PATH = (get_global_nodejs_path() or "")
              .. ":"
              .. vim.env.PATH:gsub(vim.fn.expand("~") .. "/.asdf/shims:", ""),
          },
        },
      },
    },
  },
  {
    "dmmulroy/ts-error-translator.nvim",
    config = function()
      require("ts-error-translator").setup()
    end,
  },
}
