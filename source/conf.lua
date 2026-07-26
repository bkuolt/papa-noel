function love.conf(t)
    t.window.vsync = false
    t.window.fullscreen = true
end

local config = {
    ShowGrid = true,   -- Show grid on/off
    ScrollSpeed = 500, -- In pixels/s
    mode = "Game",
    ShowBoundingBoxes = false
}

return config
