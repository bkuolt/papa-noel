-- Copyright 2019 Bastian Kuolt
local json = require("json")

function loadConfig()
    return;  -- TODO
end 

if false then
    local config = json.parse("config.json")
    -- TODO: set icon
    -- TODO: set resolution
    love.window.setFullscreen(true);
    print("loaded config")
end