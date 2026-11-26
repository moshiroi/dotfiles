-- Rex key bindings. Run `rex config reload` after editing a live copy.

-- Zellij-style pane focus on the RIGHT Option key: right Option plus an
-- arrow or h/j/k/l. Rex's own cmd+alt+arrow bindings still work too.
--
-- Rex binds "alt" without caring which Option key is held, so each key runs
-- a function that checks the side itself. The key event's mods read
-- "alt+alt_side" for the right Option key and "alt" for the left. Returning
-- false hands the key on to the terminal unchanged, so the LEFT Option key
-- keeps its usual meaning: word jumps with Option+Left/Right, and zsh's and
-- Helix's own alt bindings.
local directions = {
  left = "left",
  right = "right",
  up = "up",
  down = "down",
  h = "left",
  j = "down",
  k = "up",
  l = "right",
}

local function right_option(ev)
  local mods = "+" .. (ev.mods or "") .. "+"
  return mods:find("+alt_side+", 1, true) ~= nil
end

for key, direction in pairs(directions) do
  rex.bind("alt+" .. key, function(ctx, ev)
    if not right_option(ev) then
      return false
    end
    rex.session.focus_direction{
      session_id = ctx.session_id,
      direction = direction,
    }
    return true
  end)
end
