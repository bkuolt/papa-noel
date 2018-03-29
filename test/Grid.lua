config = require("conf")

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
        backgroundScroll = { x = 0, y = 0 },
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
    return math.floor((x - self.position.x) / tileWidth), math.floor((y - self.position.y) / tileHeight)
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
    -- TODO: delete empty tiles (tiles without images)
end

function Grid:addTile(column, row, image)
    self.tiles[row] = self.tiles[row] or {}
    self.tiles[row][column] = {}
    self.tiles[row][column].image = image
end

function Grid:setBackground(image)
    self.background = image
end

function Grid:drawGrid()
    local grey = function(value) 
        return value, value, value, 255
    end

    local tileWidth, tileHeight = self:getTileDimensions()

    love.graphics.push()
        love.graphics.setLineWidth(1)
        love.graphics.setColor(grey(64))
        
        love.graphics.origin()
        love.graphics.translate(self.position.x % tileWidth, self.position.y % tileHeight)

        for y = -1, self.rows + 1 do
            for x = -1, self.columns + 1 do
                love.graphics.rectangle("line", x * tileWidth, y * tileHeight, tileWidth, tileHeight)
            end
        end
    love.graphics.pop()
end

time = love.timer.getTime()


function Grid:scrollBackground(offset)
    self.backgroundScroll.x = self.backgroundScroll.x + offset
end

function Grid:drawBackground()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local imageWidth, imageHeight = self.background:getData():getDimensions()
    
    love.graphics.push()
        local translation = self.backgroundScroll.x % screenWidth

        love.graphics.draw(self.background,  translation, 0, 0,  screenWidth / imageWidth, screenHeight / imageHeight)
        love.graphics.draw(self.background,  translation + screenWidth, 0, 0, screenWidth / imageWidth, screenHeight / imageHeight)
        love.graphics.draw(self.background,  translation - screenWidth, 0, 0, screenWidth / imageWidth, screenHeight / imageHeight)
        
    love.graphics.pop()

end

function Grid:drawTiles()
    local tileWidth, tileHeight = self:getTileDimensions()

    love.graphics.push()
        love.graphics.translate(self.position.x, self.position.y)
        love.graphics.setColor(255, 255, 255)

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
    love.graphics.pop()
end

function Grid:draw()
    --if self.background then 
      --  self:drawBackground()
    --end

    if config.ShowGrid then
        self:drawGrid()
    end

    self:drawTiles()
end

function Grid:scroll(x, y)
    self.position.x = self.position.x + x
    self.position.y = self.position.y + y

    self:scrollBackground(x / 2)
end

return Grid