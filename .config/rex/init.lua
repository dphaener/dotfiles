-- tmux-style bindings, mirroring ~/dotfiles/.tmux.conf (prefix C-a)
local P = "ctrl+a>"

-- Press the prefix twice to send C-a to the terminal (send-prefix)
rex.bind(P .. "ctrl+a", "pane.send_key", { key = "ctrl+a" })

-- Your splits: v = side by side, s = stacked
rex.bind(P .. "v", "pane.split", { direction = "right" })
rex.bind(P .. "s", "pane.split", { direction = "down" })
-- tmux defaults, kept for muscle memory: % and "
rex.bind(P .. "shift+5", "pane.split", { direction = "right" })
rex.bind(P .. "shift+'", "pane.split", { direction = "down" })

-- Your vim-style pane movement
rex.bind(P .. "h", "pane.focus", { direction = "left" })
rex.bind(P .. "j", "pane.focus", { direction = "down" })
rex.bind(P .. "k", "pane.focus", { direction = "up" })
rex.bind(P .. "l", "pane.focus", { direction = "right" })
rex.bind(P .. "o", "pane.focus_next")
rex.bind(P .. ";", "pane.focus_previous")

-- Panes
rex.bind(P .. "z", "pane.zoom")
rex.bind(P .. "x", "pane.close")
rex.bind(P .. "shift+1", "pane.move_to_new_tab")   -- !
rex.bind(P .. "shift+[", "pane.move", { direction = "left" })  -- {
rex.bind(P .. "shift+]", "pane.move", { direction = "right" }) -- }
rex.bind(P .. "space", "pane.balance")

-- Windows (Rex tabs)
rex.bind(P .. "c", "client.tab.new")
rex.bind(P .. "n", "client.tab.next")
rex.bind(P .. "p", "client.tab.previous")
rex.bind(P .. ",", "client.tab.rename")
rex.bind(P .. "shift+7", "client.tab.close")       -- &
for i = 1, 9 do                                    -- base-index 1
  rex.bind(P .. i, "client.tab.goto", { index = i })
end

-- Sessions (s is your split key, so w opens the picker)
rex.bind(P .. "w", "session.switch")
rex.bind(P .. "shift+4", "session.rename")         -- $
rex.bind(P .. "shift+9", "session.previous")       -- (
rex.bind(P .. "shift+0", "session.next")           -- )

-- Misc
rex.bind(P .. "[", "client.find.open")             -- closest thing to copy mode
rex.bind(P .. "shift+;", "client.palette.toggle")  -- : on a US layout
rex.bind(P .. "r", "client.config.reload")

-- Resize mode: prefix then R, then hjkl (shift for big steps), Esc to leave
rex.mode("resize", { exclusive = true })
rex.bind(P .. "shift+r", "client.mode.enter", { name = "resize" })
for key, dir in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  rex.bind("resize/" .. key, "pane.resize", { direction = dir })
  rex.bind("resize/shift+" .. key, "pane.resize", { direction = dir, amount = 15 })
end
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")
