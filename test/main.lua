ShowGrid = true   -- show grid on/off
ScrollSpeed = 500 -- in pixels/s

Grid = require("Grid")
require("SaveGame")

local currentImageIndex = 1         -- the currently seleted image
local currentCell = {x = 0, y = 0}
local images = {}

local function loadTiles(path)
    assert(love.filesystem.isDirectory(path), "invalid path")
    
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
    currentImageIndex = (currentImageIndex + offset) % (1 + #images) -- TODO
    print(offset)
end

--[[
----------------------------------------------------
Mouse Callbacks
----------------------------------------------------]]
function love.mousemoved(x, y, dx, dy, istouch)
    currentCell.x, currentCell.y = grid:getTileIndices(x,y) -- TODO
    
    if love.mouse.isDown(1) then -- left mouse button pressed and mouse moved
        love.mouse.setCursor(love.mouse.getSystemCursor("crosshair"))
        grid:scroll(dx, dy)
    else
        local tile = grid:getTile(x, y)
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
        local tile = grid:getTile(x, y)
        
        love.mouse.setCursor(love.mouse.getSystemCursor("sizens"))

        if tile ~= nil and tile.image ~= nil then
            scrollCurrentImage(1)
            print("sd")
        end

        grid:setTile(x, y, images[currentImageIndex])
    elseif button == 2 then -- right click on set tile -> eras tile
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        grid:setTile(x, y, nil)
    end
end

function love.wheelmoved(x, y)
    scrollCurrentImage(y)

    -- update tile image
    local x, y = love.mouse.getPosition()
    grid:setTile(x, y, images[currentImageIndex])
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
        ShowGrid = not ShowGrid -- toggle grid visibility
    end
end

function love.update(delta)
    local scrollOffset = { x = 0, y = 0 }

    if love.keyboard.isDown("left") then
        scrollOffset.x = ScrollSpeed * delta
    elseif love.keyboard.isDown("right") then
        scrollOffset.x = -ScrollSpeed * delta
    end
    if love.keyboard.isDown("up")then
        scrollOffset.y = ScrollSpeed * delta
    elseif love.keyboard.isDown("down") then
        scrollOffset.y = -ScrollSpeed * delta
    end

    -- TODO: update mouse cursor when moving
    grid:scroll(scrollOffset.x, scrollOffset.y)
end

--[[
----------------------------------------------------
Initialization
----------------------------------------------------]]
function love.load() 
    love.window.setFullscreen(true)
    love.window.setTitle("Papa Noel Level Editor")
    love.graphics.setDefaultFilter("linear", "linear")

    loadTiles("Tiles/")

    if not LoadGrid(images) then 
         grid = createGrid(16, 8)
    end

    local backgroundImage = love.graphics.newImage("background.png")
    grid:setBackground(backgroundImage)
end

function love.conf(t)
    t.window.vsync = false
    t.window.fullscreen = true
end

function love.draw()
    love.graphics.clear(32, 32, 32)
    grid:draw()

    local text = string.format("Tile %d/%d",currentCell.x, currentCell.y)
    love.graphics.print(text,0,0)
end