-- display_layout.lua
-- Export und import of display-arrangements to/from ~/.hammerspoon/display_layout.json
-- 
-- Usage:
--   place this file in ~/.hammerspoon/
-- 
--   in init.lua add: 
--   require("display_layout")
--   hs.hotkey.bind({"cmd","ctrl"}, "E", exportDisplayLayout)
--   hs.hotkey.bind({"cmd","ctrl"}, "I", importDisplayLayout)

local LAYOUT_FILE = os.getenv("HOME") .. "/.hammerspoon/display_layout.json"

-- identification per UUID (more stable than name or ID)
local function getScreenKey(screen)
    return screen:getUUID()
end

-- Export: save current layout to json
function exportDisplayLayout()
    local layout = {}
    local primary = hs.screen.primaryScreen()

    for _, screen in ipairs(hs.screen.allScreens()) do
        local frame = screen:fullFrame()
        local entry = {
            uuid     = screen:getUUID(),
            name     = screen:name(),
            x        = frame.x,
            y        = frame.y,
            w        = frame.w,
            h        = frame.h,
            isPrimary = (screen == primary),
        }
        table.insert(layout, entry)
    end

    local json = hs.json.encode(layout, true)
    local file = io.open(LAYOUT_FILE, "w")
    if file then
        file:write(json)
        file:close()
        hs.notify.new({
            title = "Display Layout",
            informativeText = "Layout saved (" .. #layout .. " Displays)"
        }):send()
    else
        hs.alert("Error: Could not write file: " .. LAYOUT_FILE)
    end
end

-- Import: restore saved file from json
function importDisplayLayout()
    local file = io.open(LAYOUT_FILE, "r")
    if not file then
        hs.alert("No layout found:\n" .. LAYOUT_FILE)
        return
    end

    local json = file:read("*a")
    file:close()

    local layout = hs.json.decode(json)
    if not layout then
        hs.alert("Fehler: JSON konnte nicht gelesen werden.")
        return
    end

    -- Index of current screens by UUID
    local currentScreens = {}
    for _, screen in ipairs(hs.screen.allScreens()) do
        currentScreens[screen:getUUID()] = screen
    end

    local applied = 0
    local missing = {}

    for _, entry in ipairs(layout) do
        local screen = currentScreens[entry.uuid]
        if screen then
            -- setOrigin moves the screen in the macOS coord-system
            screen:setOrigin(entry.x, entry.y)
            applied = applied + 1
        else
            table.insert(missing, entry.name .. " (" .. entry.uuid .. ")")
        end
    end

    local msg = "Layout applied: " .. applied .. " Displays."
    if #missing > 0 then
        msg = msg .. "\Not found:\n" .. table.concat(missing, "\n")
    end

    hs.notify.new({
        title = "Display Layout",
        informativeText = msg
    }):send()
end

-- Hotkeys
-- hs.hotkey.bind({"cmd", "ctrl"}, "E", exportDisplayLayout)
-- hs.hotkey.bind({"cmd", "ctrl"}, "I", importDisplayLayout)

-- Optional: Auto-Restore on display-change
-- be careful with this! 
-- hs.screen.watcher.new(function()
--     hs.timer.doAfter(2, importDisplayLayout)
-- end):start()
