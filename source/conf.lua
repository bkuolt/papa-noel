function love.conf(t)
    t.version = "11.5"
    t.window.title = "Papá Noel"
    t.window.vsync = 1
    t.window.fullscreen = true
end

local config = {
    ShowGrid = true,   -- Show grid on/off
    ScrollSpeed = 500, -- Scroll speed in pixels/s
    mode = "Game",
    ShowBoundingBoxes = false
}

return config
