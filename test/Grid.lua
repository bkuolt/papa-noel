config = require("conf")

--[[
----------------------------------------------------
Tile iterator
----------------------------------------------------]]
local function getNextColumn(tiles, x, y)
    return next(tiles[y], x)
end

local function getNextRow(tiles, y)
    return next(tiles, y)
end

local function skipEmptyTiles(tiles, x, y)
    if x == nil and y == nil then 
        return 
    end

    while tiles[y][x] == nil or tiles[y][x].image == nil do
        x, y = getNextTile(tiles, x, y)
    end
    
    return x, y
end

local function getFirstTile(tiles)
    local y = getNextRow(tiles, nil)
    if y == nil then return end -- empty table
    local x = getNextColumn(tiles, nil, y)
    if x == nil then return end -- empty table

    x,y = skipEmptyTiles(tiles, x, y)
    return x, y
end

local function getNextTile(tiles, x, y)
    x = getNextColumn(tiles, x, y)
    if x == nil then
        y = getNextRow(tiles, y)
        if y == nil then return end -- iteration finished
        x = getNextColumn(tiles, nil, y)
        if x == nil then return end -- iteration finished
    end
    return x, y
end

function tiles(grid)
    if grid == nil then 
        return function()
            return
        end
    end

    -- get first tile
    local current = {}
    current.x, current.y = getFirstTile(grid.tiles)

    return function()
        if current.x == nil and current.y == nil then 
            return  -- no more tiles
        end

        tmp = {}
        tmp.x, tmp.y = current.x, current.y 

        current.x, current.y = getNextTile(grid.tiles, current.x, current.y)  
        current.x, current.y = skipEmptyTiles(grid.tiles, current.x, current.y)  

        return grid.tiles[tmp.y][tmp.x], tmp.x, tmp.y
    end
end

--[[
----------------------------------------------------
 Grid
----------------------------------------------------]]
local Grid = {}

function createGrid(columns, rows)
    assert(columns ~= nil and rows ~= nil and columns > 0 and rows > 0, "Invalid grid size")

    local grid = {
        rows = rows,       -- maximum number of rows in the grid on the screen 
        columns = columns, -- maximum number of columns in the grid on the screen
        scrollOffset = { x = 0, y = 0 },
        tiles = {}
    }
    setmetatable(grid, {__index = Grid})

    print("Created " ..rows.. "x" ..columns.. " grid")
    return grid
end

function Grid:getTileDimensions()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    return screenWidth / self.columns , screenHeight / self.rows
end

function Grid:getTileIndices(x, y)
    local tileWidth, tileHeight = self:getTileDimensions()
    return math.floor((x - self.scrollOffset.x) / tileWidth), math.floor((y - self.scrollOffset.y) / tileHeight)
end

function Grid:getTile(column, row)
    assert(row ~= nil and column ~= nil, "Invalid tile indices")

    if self.tiles[row] == nil or self.tiles[row][column] == nil or  self.tiles[row][column].image == nil then 
        return nil 
    end
    return self.tiles[row][column]
end

function Grid:removeTile(column, row)
    local tile = self:getTile(column, row)
    if tile == nil then
        return -- no tile to delete
    end
    self.tiles[row][column] = nil
end

function Grid:setTile(column, row, image)
    assert(image ~= nil, "Invalid tile image")

    self.tiles[row] = self.tiles[row] or {}
    self.tiles[row][column] = self.tiles[row][column] or {}
    self.tiles[row][column].image = image 
end

function Grid:getLimits()
    local max = { x = -math.huge }
    local min = { x =  math.huge }
    
    for tile, x, y in tiles(self) do 
        max.x = math.max(max.x, x)
        min.x = math.min(min.x, x)
    end

    return min.x, max.x
end

function Grid:scroll(x, y)
    -- TODO: perform horizontal checks
    self.scrollOffset.x = self.scrollOffset.x + x
    self.scrollOffset.y = self.scrollOffset.y + y

    if config.mode == "Editor" then
        return true -- no need for checks in Editor mode
    end

    local firstTileIndex, lastTileIndex = self:getLimits()
   
    if firstTileIndex ~= nil then
        local tileWidth = self:getTileDimensions()
        local screenWidth = self.columns * tileWidth
        local lastTilePosition = (lastTileIndex + 1) * tileWidth
        local firstTilePosition = firstTileIndex * tileWidth

        --[[
           ==========--------
           | Screen | World |
           =========x--------
        ]]
        if -self.scrollOffset.x <= firstTilePosition then 
            self.scrollOffset.x = -firstTilePosition
            return false
        end
        
        --[[
           ---------=========
           | World | Screen |
           --------x=========
        ]]
        if -self.scrollOffset.x + screenWidth >= lastTilePosition then
            self.scrollOffset.x = - (lastTilePosition - screenWidth)
            return false
        end
    end
    
    return true
end

function Grid:drawGrid()
    local tileWidth, tileHeight = self:getTileDimensions()

    love.graphics.push("all")
        love.graphics.setLineWidth(1)
        love.graphics.setColor(0.5, 0.5, 0.5)
        
        love.graphics.origin()
        love.graphics.translate(self.scrollOffset.x % tileWidth, self.scrollOffset.y % tileHeight)

        for y = -1, self.rows + 1 do
            for x = -1, self.columns + 1 do
                love.graphics.rectangle("line", x * tileWidth, y * tileHeight, tileWidth, tileHeight)
            end
        end
    love.graphics.pop()
end

function Grid:isMarkedForDeletetion()
    -- TODO
end

function Grid:getVisibleRange()
    local min = {x = 0}
    local max = {x = 0}
    
    local tileWidth = self:getTileDimensions();

    min.x = math.floor(-self.scrollOffset.x / tileWidth)
    max.x = min.x + math.floor(love.graphics.getWidth() / tileWidth)

    print(min.x, "/" ,max.x)
    return min, max
end



function Grid:drawTiles()
    local tileWidth, tileHeight = self:getTileDimensions()

    love.graphics.push()
        love.graphics.translate(self.scrollOffset.x, self.scrollOffset.y)

        for tile, x, y in tiles(self) do
            local imageWidth, imageHeight = tile.image:getDimensions()
            love.graphics.draw(tile.image, x * tileWidth, y * tileHeight, 0,
                               tileWidth / imageWidth, tileHeight / imageHeight)
        end

    love.graphics.pop()
end

function Grid:draw()
    if config.ShowGrid then
        self:drawGrid()
    end

    self:drawTiles()
end

return Grid

