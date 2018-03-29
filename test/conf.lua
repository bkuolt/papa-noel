function love.conf(t)
    t.window.vsync = false
    t.window.fullscreen = true
end

local config = {
    ShowGrid = true,   -- show grid on/off
    ScrollSpeed = 500 -- in pixels/s
}

return config
