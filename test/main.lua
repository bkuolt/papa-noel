ShowGrid = true   -- show grid on/off
ScrollSpeed = 500 -- in pixels/s

Grid = require("Grid")

-- -----------------------------------------------------------------------------------------

local function loadTiles(path)
    assert(love.filesystem.isDirectory(path), "invalid path")
    
    -- ensure trailing '/'
    if string.sub(path, -1) ~= "/" then
        path = path .. "/"
    end

    local images = {}
    
    -- load all images from the specified path 
    local files = love.filesystem.getDirectoryItems(path)
    for index, file in ipairs(files) do
        images[#images + 1] = love.graphics.newImage(path .. file)
    end

    print("Loaded " ..#images.. " tiles")
    return images
end

local images = loadTiles("Tiles/")
local currentImageIndex = 1 -- the currently seleted image

local function getIndexFromImage(image)
    for i = 1, #images do 
        if images[i] == image then
            return i 
        end
    end
    return 0
end

--[[
----------------------------------------------------
Saving and Restoring the world
----------------------------------------------------]]
GridFile = "world.data"

function SaveGrid()
    assert(grid ~= nil, "No world to save")
    
    local file = io.open(GridFile, "w+")
    file:write(2, "\n")                            -- write version
    file:write(grid.rows, " ", grid.columns, "\n") -- write world size
    file:write(grid.position.x, "\n")              -- write scroll offset
    file:write(grid.position.y, "\n")

     -- write tiles
    for y = 1, grid.rows do
        for x = 1, grid.columns do 
            local tile = grid.tiles[y][x]
            if tile.image ~= nil then
                file:write(x, " ", y, " ", getIndexFromImage(tile.image), "\n")
            end
        end
    end

    file:close()
    print("Saved world")
end

function LoadGrid()
    local file = io.open(GridFile, "r")
    
    if file == nil then
        print("No world exists to load")
        return
    end
    
    local version = file:read("*number") -- read version 
    local rows = file:read("*number")    -- read and create world of appropriate size
    local columns = file:read("*number")
    local scrollOffset = {               -- read scroll offset
        x = file:read("*number"),
        y = file:read("*number")
    }

    if version == nil or 
       rows == nil or columns == nil or 
       scrollOffset.x == nil or scrollOffset.y == nil then
        return false
    end

    -- create new grid
    grid = createGrid(columns, rows)
    grid:scroll(scrollOffset.x, scrollOffset.y)

    -- read all saved tiles
    local tileCount = 0
    while true do
        local x = file:read("*number")
        if x == nil then
            break -- no (more) tiles to read
        end

        local y = file:read("*number")
        local imageIndex = file:read("*number")
        
        -- TODO: check if world is large enoug for tile
        grid.tiles[y][x].image = images[imageIndex]
        tileCount = tileCount + 1
    end

    file:close()
    print(string.format("Restored %d tiles from %dx%d world", tileCount, rows, columns))
    return true
end

--[[
----------------------------------------------------
Mouse Callbacks
----------------------------------------------------]]
function love.mousemoved(x, y, dx, dy, istouch)
    if love.mouse.isDown(1) then -- left mouse button pressed and mouse moved
        love.mouse.setCursor(love.mouse.getSystemCursor("crosshair"))
        grid:scroll(dx, dy)
    else
        local tile = grid:getTile(x, y)
        if tile == nil then
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
        elseif tile.image == nil then -- mouse over empty tile
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        else -- mouse over set tile
            love.mouse.setCursor(love.mouse.getSystemCursor("sizens"))
            currentImageIndex = getIndexFromImage(tile.image)
        end
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        local tile = grid:getTile(x, y)
        if tile ~= nil and tile.image == nil then -- left click on empty tile -> set tile
            love.mouse.setCursor(love.mouse.getSystemCursor("sizens"))
            grid:setTile(x, y, images[currentImageIndex])
        end
    elseif button == 2 then -- right click on set tile -> eras tile
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        grid:setTile(x, y, nil)
    end
end

function love.wheelmoved(x, y)
    -- scroll current image
    currentImageIndex = (currentImageIndex + y) % #images

    -- update tile image
    x, y = love.mouse.getPosition()
    grid:setTile(x, y, images[currentImageIndex])
end

--[[
----------------------------------------------------
Keyboard Callbacks
----------------------------------------------------]]
function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        SaveGrid()
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

    if not LoadGrid() then 
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
end
