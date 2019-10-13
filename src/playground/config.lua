-- Copyright 2019 Bastian Kuolt

function loadConfig()
    love.window.minimize();
    local config = json.parse("config.json")
    -- TODO: set icon
    -- TODO: set resolution
    love.window.setFullscreen(true);
    print("loaded config")
end