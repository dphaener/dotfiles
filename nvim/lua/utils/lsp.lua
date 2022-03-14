local Job = require("plenary.job")
local a = require "async"
local has_value = require("utils.table").has_value

local M = {}
local argument_map = {
  npm = {
    test = { cmd = "npm", args = { "-g", "list" } },
    install = { cmd = "npm", args = { "-g", "install" } },
  },
  gem = {
    test = { cmd = "gem", args = { "list" } },
    install = { cmd = "gem", args = { "install" } },
  }
}
local server_definitions = {
  cssls = { cmd = "npm", library = "vscode-langservers-extracted" },
  eslint = { cmd = "npm", library = "vscode-langservers-extracted" },
  html = { cmd = "npm", library = "vscode-langservers-extracted" },
  jsonls = { cmd = "npm", library = "vscode-langservers-extracted" },
  solargraph = { cmd = "gem", library = "solargraph" },
  tailwindcss = { cmd = "npm", library = "@tailwindcss/language-server" },
  tsserver = { cmd = "npm", library = "typescript-language-server" },
}

local check_for_server = function(server, _, callback)
  local server_definition = server_definitions[server]
  local commands = argument_map[server_definition.cmd]
  table.insert(commands.test.args, server_definition.library)

  return Job:new({
    command = commands.test.cmd,
    args = commands.test.args,
    on_exit = function(j, return_val)
      callback(j:result())
    end,
  }):start()
end

local install_server = function(server, _, callback)
  local server_definition = server_definitions[server]
  local commands = argument_map[server_definition.cmd]
  table.insert(commands.install.args, server_definition.library)

  return Job:new({
    command = commands.install.cmd,
    args = commands.install.args,
    on_exit = function(j, return_val)
      callback(j:result())
    end,
  }):start()
end

local check_serv = a.wrap(check_for_server)
local inst_serv = a.wrap(install_server)

local install_server = function(server)
  return a.sync(function()
    local res = a.wait(check_serv(server, ""))
    local server_definition = server_definitions[server]
    local library = server_definition.library

    if not has_value(res, library) then
      print("Installing " .. library .. "...")
      local res = a.wait(inst_serv(server, ""))
      print("Successfully installed " .. library .. ".")
    end
  end)
end

function M.install_servers(servers)
  return a.sync(function ()
    for _, server in ipairs(servers) do
      a.wait(install_server(server))
    end
  end)()
end

return M
