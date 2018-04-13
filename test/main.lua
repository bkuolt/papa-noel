config = require("conf")
require("Level")
require("SaveGame")
--require("Animation")
LevelEditor = require("LevelEditor")

function toggleMode()
    if config.mode ~= "Editor" then
         config.mode = "Editor"
    else 
        config.mode = "Game"
    end

    love.mouse.setVisible(config.mode == "Editor")
    config.ShowGrid = not config.ShowGrid -- toggle grid visibility
end


--[[
----------------------------------------------------
Mouse Callbacks
----------------------------------------------------]]
function love.mousepressed(x, y, button, istouch)
    if config.mode == "Editor" then
        LevelEditor.onClick(x, y, button)
    end
end

function love.wheelmoved(dx, dy)
    if config.mode == "Editor" then 
        local x, y = love.mouse.getPosition()
        LevelEditor.onMouseWheelMoved(x, y, dy)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if config.mode == "Editor" then 
        LevelEditor.onMouseMove(x, y, dx, dy)
    end
end

--[[
----------------------------------------------------
Keyboard Callbacks
----------------------------------------------------]]
function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        SaveGrid(images)
        love.event.quit() -- terminate
    elseif key == "p" then
        -- TODO: implement pause mode
    elseif key == "space" then
        toggleMode()
    end
end

--[[
----------------------------------------------------
Initialization
----------------------------------------------------]]
function love.load() 
    love.window.setTitle("Papa Noel Level Editor")
    love.graphics.setDefaultFilter("linear", "linear")
    love.mouse.setVisible(false)

    LoadLevel()
end

function love.update(delta)
    local scrollOffset = { x = 0, y = 0 }

    if love.keyboard.isDown("left") then
        scrollOffset.x = config.ScrollSpeed * delta
    elseif love.keyboard.isDown("right") then
        scrollOffset.x = -config.ScrollSpeed * delta
    end
    if love.keyboard.isDown("up")then
        scrollOffset.y = config.ScrollSpeed * delta
    elseif love.keyboard.isDown("down") then
        scrollOffset.y = -config.ScrollSpeed * delta
    end

    -- TODO: update mouse cursor when moving
    level:scroll(scrollOffset.x, scrollOffset.y)

    level:update(delta)
end

local function PrintStatistics()
    local statistics = love.graphics.getStats()

    local text = string.format("%d drawcalls (%d batched) | %d MB textures | %d FPS", 
                               statistics.drawcalls, statistics.drawcallsbatched, statistics.texturememory / 1024^2, love.timer.getFPS())
    love.graphics.print(text,0,0)
end

function love.draw()
    love.graphics.clear(0, 0, 0)
    level:draw()
    PrintStatistics()
end