local M = {}

function M.has_value(tab, val)
  for index, value in ipairs(tab) do
    if value:find(val, 1, true) ~= nil then
      return true
    end
  end

  return false
end

return M
