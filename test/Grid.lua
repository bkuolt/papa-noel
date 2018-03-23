--[[
----------------------------------------------------
 Grid
----------------------------------------------------]]
local Grid = {}

function createGrid(columns, rows)
    assert(columns ~= nil and rows ~=nil and columns > 0 and rows > 0, "Invalid grid size")

    local grid = {
        columns = columns,
        rows = rows,
    }
    setmetatable(grid, {__index = Grid})

    grid.position = { x = 0, y = 0 }
    grid.tiles = {}

    -- create all tiles
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
    return screenWidth / self.columns , screenHeight / self.rows
end

function Grid:isWithin(x, y)
    -- TODO
end

function Grid:getTile(x, y)
    local tileWidth, tileHeight = self:getTileDimensions()
    local row, column = math.floor(y / tileHeight), math.floor((x - self.position.x) / tileWidth)

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
    end
end

function Grid:setBackground(image)
    self.background = image
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

function Grid:drawBackground()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local imageWidth, imageHeight = self.background:getData():getDimensions()
    love.graphics.draw(self.background, 0, 0, 0, screenWidth / imageWidth, screenHeight / imageHeight)
end

function Grid:drawTiles()
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

function Grid:draw()
    if self.background then 
        self:drawBackground()
    end

    love.graphics.translate(self.position.x, self.position.y)

    if ShowGrid then
        self:drawGrid()
    end

    self:drawTiles()
end

function Grid:scroll(x, y)
    self.position.x = self.position.x + x
    self.position.y = self.position.y + y
end

return Grid