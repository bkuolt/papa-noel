ShowGrid = true -- show grid on/off


--[[
----------------------------------------------------
 Grid
----------------------------------------------------]]
local Grid = {}

function createGrid(columns, rows)
    local grid = {
        columns = columns,
        rows = rows,
    }
    setmetatable(grid, {__index = Grid})

    grid.x = 0

    -- create all tiles
    grid.tiles = {}
    for i = 0, rows do
        grid.tiles[i] = {}
        for j = 0, columns do
            grid.tiles[i][j] = { index = 0 }
        end
    end

    print("Created " ..rows.. "x" ..columns.. " grid")
    return grid
end

function Grid:getTileDimensions()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    return screenWidth / self.columns, screenHeight / self.rows
end

function Grid:getTile(x, y)
    local tileWidth, tileHeight = self:getTileDimensions()
    local row, column = math.floor(y / tileHeight), math.floor((x - self.x) / tileWidth)

    -- check if coordinates are out of bounce
    local isOutOfBounce = row < 0 or row > self.rows or column < 0 or column > self.columns
    if isOutOfBounce then
        return nil
    end

    return self.tiles[row][column]
end

function Grid:setTile(x, y, image)
    local tile = self:getTile(x, y)
    if tile ~= nil then
        tile.image = image 
    else
        -- ERROR !? 
    end
end

function Grid:drawGrid()
    local grey = function(value) 
        return value, value, value, 255
    end

    love.graphics.setLineWidth(1)
    love.graphics.setColor(grey(64))
    
    local tileWidth, tileHeight = self:getTileDimensions()
    for y = 0, self.columns do
        for x = 0, self.rows do
            love.graphics.rectangle("line", x * tileWidth, y * tileHeight, tileWidth, tileHeight)
        end
    end
end

function Grid:draw()
    love.graphics.translate(self.x, 0)

    if ShowGrid then
        self:drawGrid()
    end

    love.graphics.setColor(255, 255, 255)
    local tileWidth, tileHeight = self:getTileDimensions()
    for y = 0, self.columns do
        for x = 0, self.rows do
            local image = self.tiles[y][x].image
            if image ~= nil then
                local imageWidth, imageHeight = image:getData():getDimensions()
                love.graphics.draw(image, x * tileWidth, y * tileHeight, 0,
                                   tileWidth / imageWidth, tileHeight / imageHeight)
            end
        end
    end
end

function Grid:scroll(offset)
    self.x = self.x + offset
end


function loadTiles(path)
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

-- ..........................................................................

local images = loadTiles("Tiles/")

local currentImageIndex = 1 -- the currently seleted image

-- ..........................................................................
local function getIndexFromImage(image)
    for i = 1, #images do 
        if images[i] == image then
            return i 
        end
    end
    return 0
end

-- --------------------------------------------------------------------------------------------------

--[[
 @brief Saves the current world so it can be restored on the next restart
]]
function SaveGrid()
    assert(grid ~= nil)
    
    local file = io.open("world.data", "w+")
    file:write(2, "\n")                            -- write version
    file:write(grid.rows, " ", grid.columns, "\n") -- write world size
    file:write(grid.x, "\n")                       -- write scroll offset

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

--[[
 @brief Restores previously saved world
]]
function LoadGrid()
    local file = io.open("world.data", "r")
    
    if file == nil then
        print("No world exists to load")
        return
    end
    
    local version = file:read("*number") -- read version 
    local rows = file:read("*number")    -- read and create world of appropriate size
    local columns = file:read("*number")
    local offset = file:read("*number")  -- read scroll offset

    if version == nil or rows == nil or columns == nil or offset == nil then
        return false
    end

    -- create new grid
    grid = createGrid(columns, rows)
    grid:scroll(offset)

    -- read tiles
    local tileCount = 0
    while true do
        local x = file:read("*number")
        if x == nil then
            break
        end

        local y = file:read("*number")
        local imageIndex = file:read("*number")

        grid.tiles[y][x].image = images[imageIndex]
        tileCount = tileCount + 1
    end

    file:close()
    print(string.format("Restored %d tiles from %dx%d world", tileCount, rows, columns))
    return true
end

-- --------------------------------------------------------------


function love.wheelmoved(x, y)
    -- scroll current image
    local offset = 0
    if y > 0 then offset = 1 elseif y < 0 then offset = -1 end
    currentImageIndex = (currentImageIndex + offset) % #images

    -- update tile
    x, y = love.mouse.getPosition()
    grid:setTile(x, y, images[currentImageIndex])
end

function love.mousemoved(x, y, dx, dy, istouch)
    -- (1) get Index from current cell image
    -- (2) set current image ondex to it
    -- (3) update image
end

function love.mousepressed(x, y, button, istouch)
    local image 

    if button == 1 then
        local tile = grid:getTile(x, y)
        if tile ~= nil and tile.image ~= nil then
            currentImageIndex = getIndexFromImage(tile.image)
            image = images[currentImageIndex]
        end 
    elseif button == 2 then             
        image = nil                       -- erase current tile
    end

    grid:setTile(x, y, image)
end

--[[
Scroll the world
--]]
local keys = {}

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        SaveGrid()
        love.event.quit()            -- terminate
    elseif key == "space" then
        ShowGrid = not ShowGrid      -- toggle show grid
    else
        keys[key] = {}
        keys[key].down = true
        keys[key].timestamp = love.timer.getTime()
    end
end

function love.keyreleased(key)
    keys[key] = {}
    keys[key].down = false
end

function love.update(delta)
    local scrollOffset = 0

    if keys["left"] and keys["left"].down then
        keys["left"].timestamp = love.timer.getTime()
        scrollOffset = 1
    elseif keys["right"] and keys["right"].down then
        keys["right"].timestamp = love.timer.getTime()
        scrollOffset = -1
    end
    scrollOffset = scrollOffset * 300 * delta

    grid:scroll(scrollOffset)
end

-- ............................................................

function love.load() 
    if not LoadGrid() then 
        grid = createGrid(8, 8)
    end

    love.window.setFullscreen(true)
    love.window.setTitle("Papa Noel Level Editor")
    love.graphics.setDefaultFilter("linear", "linear")
end


function love.conf(t)
    t.window.vsync = false
    t.window.fullscreen = true
end

function love.draw()
    love.graphics.clear(32,32,32)
    grid:draw()
end
