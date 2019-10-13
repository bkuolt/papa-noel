require("Sprite")
require("Animation")
require("SaveGame")

local Resources = require("resources")
require("Level")
LevelEditor = require("LevelEditor")

local function toggleMode()
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
        SaveLevel(level)
        love.event.quit() -- terminate
    elseif key == "p" and config.mode == "Game" then
        if level:isPaused() then 
            level:unpause()
        else
            level:pause()
        end
    elseif key == "b" then
        config.ShowBoundingBoxes = not config.ShowBoundingBoxes
    elseif key == "space" then
        toggleMode()
    end
end

--[[
----------------------------------------------------
Initialization
----------------------------------------------------]]
local function ShowLoadScreen()
    local font = love.graphics.newFont("Art/font/SF Atarian System Bold.ttf", love.graphics.getHeight() / 5)

    love.graphics.clear()
    love.graphics.push("all")
        love.graphics.setFont(font)
        love.graphics.setColor(1.0, 1.0, 1.0)
        love.graphics.print("Loading...")
    love.graphics.pop();
    love.graphics.present()
end

function love.load()
    ShowLoadScreen()

    local font = love.graphics.newFont("Art/font/SF Atarian System Bold.ttf", 30)
    love.graphics.setFont(font)

    if not LoadLevel() then 
        --print("===================> Fehler beiim Laden")
        exit()
        level = createLevel(16, 8)
    end
    level:start()
end

function love.update(delta)
    local scrollOffset = { x = 0, y = 0 }

    level:update(delta)

    if level:isPaused() then 
        return 
    end

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
end

local function PrintStatistics()
    local statistics = love.graphics.getStats()

    local text = string.format("%d FPS\n" ..
                               "%d drawcalls (%d batched) \n" ..
                               "%d textures (%d MB) \n" ..
                               "%d canvases",
                               love.timer.getFPS(),
                               statistics.drawcalls, statistics.drawcallsbatched,
                               statistics.images,statistics.texturememory / 1024^2,
                               statistics.canvases)

    love.graphics.push("all")
        love.graphics.setColor(255, 255, 255,255)
        love.graphics.print(text, 10,0)
    love.graphics.pop();
end

local function p()
    if not level:isPaused() then
        return
    end

    love.graphics.push("all")
        love.graphics.setColor(255, 0, 0, 255)
        local font = love.graphics.newFont("Art/font/SF Atarian System Bold.ttf", 100)
        love.graphics.setFont(font)

        local screenWidth, screenHeight = love.graphics.getDimensions()
        love.graphics.print("Paused", screenWidth - 250, screenHeight- 100)
    love.graphics.pop();
end

function love.draw()
    love.graphics.clear(0, 0, 0)

    level:draw()
    PrintStatistics()
    p()
end