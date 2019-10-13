-- Copyright 2019 Bastian Kuolt
local json = require("json")

function loadGame()
    local savegame = json.parse("savegame.json")
    -- TODO: if no savegame could be found start with the first level

    -- TODO: create level
    -- TODO: restore items
    -- TODO: reposition character
    -- TODO: scroll background image
    -- TODO: enter the pause mode
end

function saveGame()
    -- TODO: Save the current game and level state
end
