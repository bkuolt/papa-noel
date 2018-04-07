config = require("conf")
require("Level")
require("SaveGame")
require("Animation")


local currentImageIndex = 1         -- the currently seleted image

--[[
----------------------------------------------------
Level Editor
----------------------------------------------------]]
function toggleMode()
    if config.mode ~= "Editor" then
         config.mode = "Editor"
    else 
        config.mode = "Game"
    end

    love.mouse.setVisible(config.mode == "Editor")
    config.ShowGrid = not config.ShowGrid -- toggle grid visibility
end

local function setCurrentImage(image)
    if image == nil then
        currentImageIndex = 1
        return
    end    
    currentImageIndex = GetIndexFromImage(images, image)
end

local function getCurrentTileImage()
    return level.tileImages[currentImageIndex]
end

function scrollTileImage(tile, scrollOffset)
    setCurrentImage(tile.image)

    currentImageIndex = (currentImageIndex + scrollOffset) % #images
    currentImageIndex = math.max(1, currentImageIndex)

    tile.image = level.tileImages[currentImageIndex]
end

--[[
@brief Creates a new tile on the clicked cell in the grid or scrolls the current tiles image
@param x,y mouse coordinates in pixels
@param button currently pressed mouse button (Love2D values)
]]
local LevelEditor = {}

function LevelEditor.onClick(x, y, button)
    local column, row = level.grid:getTileIndices(x, y)

    if button == 1 then      -- (left click) set or scroll tile image
        local tile = level:getTile(column, row)
        if tile == nil then
             level:setTile(column, row, getCurrentTileImage())
        else scrollTileImage(tile, 1)
        end

        love.mouse.setCursor(love.mouse.getSystemCursor("sizens"))
    elseif button == 2 then  -- (right click) remove tile
        level:removeTile(column, row)
        setCurrentImage(nil)
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    end
end

--[[
@brief Scrolls the image, if existent, of the current grid cell 
@param x,y mouse coordinates in pixels
@param scrollOffset mouse wheel scroll units
]]
function LevelEditor.onMouseWheelMoved(x, y, scrollOffset)
    local column, row = level.grid:getTileIndices(x, y)

    local tile = level.grid:getTile(column, row)
    if tile == nil then 
        return -- no tile to scroll image for 
    end

    scrollTileImage(tile, scrollOffset)
end

function LevelEditor.onMouseMove(x, y, dx, dy)
    if love.mouse.isDown(2) then -- left mouse button pressed and mouse moved
        level:scroll(dx, dy)
        love.mouse.setCursor(love.mouse.getSystemCursor("crosshair"))
    else
        local column, row = level.grid:getTileIndices(x, y)
        local tile = level.grid:getTile(column, row)

        if tile == nil then -- mouse over empty tile
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        else -- mouse over set tile
            love.mouse.setCursor(love.mouse.getSystemCursor("sizens"))
        end
    end
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