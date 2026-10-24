local util = require("lspconfig").util

-- Get the global (~/.config/mise/config.toml) Node.js bin path for copilot
local function get_global_nodejs_path()
  local result = vim.system({ "mise", "where", "node" }, { cwd = vim.fn.expand("~"), text = true }):wait()
  if result.code ~= 0 then
    return nil
  end

  return vim.trim(result.stdout) .. "/bin"
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
          cmd = { "mise", "exec", "--", "ruby-lsp" },
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
            -- Override PATH to use the global mise Node.js instead of repo's Node.js
            PATH = (get_global_nodejs_path() or "") .. ":" .. vim.env.PATH,
          },
        },
        cssls = {
          settings = {
            css = {
              lint = {
                unknownAtRules = "ignore",
              },
            },
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
