config = require("conf")
require("HashMap2D")
require("Item") -- Tile statt Item


--[[
----------------------------------------------------
 Grid
----------------------------------------------------]]
local Grid = {}

function createGrid(columns, rows)
    assert(columns ~= nil and rows ~= nil and columns > 0 and rows > 0, "Invalid grid size")

    local grid = {}
    setmetatable(grid, {__index = Grid})

    grid.rows = rows       -- maximum number of rows in the grid on the screen 
    grid.columns = columns -- maximum number of columns in the grid on the screen
    grid.tiles = newHashMap2D()

    grid.scrollOffset = { x = 0, y = 0 }

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

function Grid:getLimits(tiles)
    local max = { x = -math.huge }
    local min = { x =  math.huge }

    for tile, x, y in tiles:iterator() do
        max.x = math.max(max.x, x)
        min.x = math.min(min.x, x)
    end

    return min.x, max.x
end

function Grid:scroll(tiles, x, y) -- TODO: perform horizontal checks
    self.scrollOffset.x = self.scrollOffset.x + x
    self.scrollOffset.y = self.scrollOffset.y + y

    if config.mode == "Editor" then
        return true -- no need for checks in Editor mode
    end

    local firstTileIndex, lastTileIndex = self:getLimits(tiles)

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

return Grid