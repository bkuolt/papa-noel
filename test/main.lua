config = require("conf")
require("Level")
require("SaveGame")


local currentImageIndex = 1         -- the currently seleted image
local images = {}

local function loadTiles(path)
    assert(love.filesystem.getInfo(path).type == "directory", "invalid path")
    
    -- ensure trailing '/'
    if string.sub(path, -1) ~= "/" then
        path = path .. "/"
    end

    -- load all images from the specified path 
    local files = love.filesystem.getDirectoryItems(path)
    for index, file in ipairs(files) do
        images[#images + 1] = love.graphics.newImage(path .. file)
    end

    print("Loaded " ..#images.. " tiles")
end

local function scrollCurrentImage(offset)
    currentImageIndex = (currentImageIndex + offset) % (1 + #images)
end

--[[
----------------------------------------------------
Mouse Callbacks
----------------------------------------------------]]
function love.mousemoved(x, y, dx, dy, istouch)
  --  currentCell.x, currentCell.y = level.grid:getTileIndices(x,y)

    if love.mouse.isDown(2) then -- left mouse button pressed and mouse moved
        love.mouse.setCursor(love.mouse.getSystemCursor("crosshair"))
        level:scroll(dx, dy)
    else
        local tile = level:getTile(x, y)
        if tile == nil or tile.image == nil then -- mouse over empty tile
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        else -- mouse over set tile
            love.mouse.setCursor(love.mouse.getSystemCursor("sizens"))
            currentImageIndex = GetIndexFromImage(images, tile.image)
        end
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then -- left click on tile
        local tile = level:getTile(x, y)
        
        love.mouse.setCursor(love.mouse.getSystemCursor("sizens"))

        if tile ~= nil and tile.image ~= nil then
            scrollCurrentImage(1)
        end

        level:setTile(x, y, images[currentImageIndex])
    elseif button == 2 then -- right click on set tile -> eras tile
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        level:removeTile(x, y)
    end
end

function love.wheelmoved(x, y)
    scrollCurrentImage(y)

    -- update tile image
    local x, y = love.mouse.getPosition()
    level:setTile(x, y, images[currentImageIndex])
end

--[[
----------------------------------------------------
Keyboard Callbacks
----------------------------------------------------]]
function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        SaveGrid(images)
        love.event.quit()       -- terminate
    elseif key == "space" then
        config.ShowGrid = not config.ShowGrid -- toggle grid visibility
    end
end

--[[
----------------------------------------------------
Initialization
----------------------------------------------------]]
function love.load() 
    love.window.setTitle("Papa Noel Level Editor")
    love.graphics.setDefaultFilter("linear", "linear")

    loadTiles("Tiles/")

    if not LoadLevel(images) then 
         level = createLevel(16, 8)
    end

    local backgroundImage = love.graphics.newImage("background.png")
    level:setBackground(backgroundImage)
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

function love.draw()
    love.graphics.clear(32, 32, 32)
    level:draw()

    local text = string.format("%d FPS", love.timer.getFPS())
    love.graphics.print(text,0,0)
end