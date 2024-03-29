-- Copy me to ~/.hammerspoon/init.lua

_G = _G
local hs = _G.hs

local function pressFn(mods, key)
  if key == nil then
    key = mods
    mods = {}
  end

  return function() hs.eventtap.keyStroke(mods, key, 1000) end
end

local function remap(mods, key, pressFn)
  hs.hotkey.bind(mods, key, pressFn, nil, pressFn)
end

remap({ 'ctrl' }, 'h', pressFn('left'))
remap({ 'ctrl' }, 'j', pressFn('down'))
remap({ 'ctrl' }, 'k', pressFn('up'))
remap({ 'ctrl' }, 'l', pressFn('right'))
remap({ 'ctrl' }, 'd', pressFn('pagedown'))
remap({ 'ctrl' }, 'u', pressFn('pageup'))
