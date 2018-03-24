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
        position = { x = 0, y = 0 },
        tiles = {}
    }
    setmetatable(grid, {__index = Grid})

    print("Created " ..rows.. "x" ..columns.. " grid") -- TODO
    return grid
end

function Grid:getTileDimensions()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    return screenWidth / self.columns , screenHeight / self.rows
end

function Grid:getTileIndices(x, y) 
    local tileWidth, tileHeight = self:getTileDimensions()
    return math.floor((x - self.position.x) / tileWidth), math.floor((y - self.position.y) / tileHeight) -- TODO
end

function Grid:getTile(x, y)
    local column, row = self:getTileIndices(x, y)

    if self.tiles[row] == nil or self.tiles[row][column] == nil then 
        return nil 
    end

    return self.tiles[row][column]
end

function Grid:setTile(x, y, image)
    local column, row = self:getTileIndices(x, y)
    
    self.tiles[row] = self.tiles[row] or {}
    self.tiles[row][column] = self.tiles[row][column] or {}
  
    self.tiles[row][column].image = image 

    print("Set ", column, "/", row, " to ", image)
    -- TODO: delete empty tiles (tiles without images)
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
    for y = 0, self.rows do
        for x = 0, self.columns do
            love.graphics.rectangle("line", x * tileWidth, y * tileHeight, tileWidth, tileHeight)
        end
    end
    -- TODO: draw infinite grid
end

function Grid:drawBackground()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local imageWidth, imageHeight = self.background:getData():getDimensions()
    love.graphics.draw(self.background, 0, 0, 0, screenWidth / imageWidth, screenHeight / imageHeight)
end

function Grid:drawTiles()
    love.graphics.setColor(255, 255, 255)
    local tileWidth, tileHeight = self:getTileDimensions()

    for y, row in pairs(self.tiles) do
        for x, _ in pairs(row) do
            local image = row[x].image
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