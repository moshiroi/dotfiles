-- Rex key bindings. Run `rex config reload` after editing a live copy.

-- Zellij-style pane focus on the RIGHT Option key: right Option plus an
-- arrow or h/j/k/l. Rex's own cmd+alt+arrow bindings still work too.
--
-- Rex binds "alt" without caring which Option key is held, so each key runs
-- a function that checks the side itself. The key event's mods read
-- "alt+alt_side" for the right Option key and "alt" for the left. Returning
-- false hands the key on to the terminal unchanged, so the LEFT Option key
-- keeps its usual meaning: word jumps with Option+Left/Right, and fish's and
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

-- Cycle through hosts, the way ctrl+tab cycles through tabs: cmd+shift+h
-- shows the next host that has a session, wrapping round at the end. The app
-- itself only offers a picker (Switch Host), so this drives it over
-- AppleScript, which is the one interface that both knows which session is
-- showing and can show a session on any host.
--
-- Coming back to a host lands on the session you left it from. `last_seen`
-- holds that per host; it lives in the server's memory, so a config reload or
-- server restart forgets it and each host starts from its first session again.
--
-- Shortcuts come from the home server (this Mac), so the key works while a
-- jarvis session is showing too. On jarvis itself the action has no
-- osascript to run and just fails, which nothing triggers.
local last_seen = {}

local cycle_script = [[
on run remembered
  tell application "Rex"
    set cur to current session
    if cur is missing value then return ""
    set curHost to host name of cur
    set curID to id of cur

    -- Sessions come host by host, so this is each host once, in sidebar order.
    set hostNames to {}
    repeat with s in every session
      set n to host name of s
      if hostNames does not contain n then set end of hostNames to n
    end repeat
    if (count of hostNames) < 2 then return curHost & tab & curID

    set nextHost to item 1 of hostNames
    repeat with i from 1 to (count of hostNames) - 1
      if item i of hostNames is curHost then set nextHost to item (i + 1) of hostNames
    end repeat

    set target to missing value
    repeat with s in every session
      if host name of s is nextHost then
        if target is missing value then set target to contents of s
        if remembered contains (id of s) then
          set target to contents of s
          exit repeat
        end if
      end if
    end repeat
    show target
    return curHost & tab & curID
  end tell
end run
]]

rex.action{
  name = "host_next",
  title = "Next Host",
  description = "Show the next host's session, cycling through every host.",
  category = "Host",
  keywords = "host remote machine server switch cycle next",
  run = function()
    local argv = { "/usr/bin/osascript", "-e", cycle_script }
    for _, session in pairs(last_seen) do
      argv[#argv + 1] = session
    end
    local r, err = rex.exec(argv, { timeout = 10 })
    if not r then
      error("host_next: " .. err)
    end
    if not r.ok then
      error("host_next: " .. r.stderr)
    end
    local host, session = r.stdout:match("^([^\t]*)\t([^\r\n]*)")
    if host then
      last_seen[host] = session
    end
  end,
}

rex.bind("cmd+shift+h", "host_next")
