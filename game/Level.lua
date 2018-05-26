require("ParticleSystem")
require("Grid")
require("HashMap2D")
require("Character")
require("Tile")

local Level = {}

function createLevel(rows, columns)
    local level = {
        backgroundScroll = { x = 0, y = 0 },
        background = nil,
        grid = createGrid(rows, columns),
        tiles = newHashMap2D(),
        items = newHashMap2D(),
        character = nil,
        paused = false,
        particleSystem = createParticleSystem(2000, Resources.particleImage, 10)
    }
    setmetatable(level, {__index = Level})

    level.tileWidth, level.tileHeight = level.grid:getTileDimensions() -- Refactor
    return level
end

--[[
----------------------------------------------------
Level content creation/retrieval
----------------------------------------------------]]
function Level:setItem(column, row, animation)
    local item = newItem(self.tileWidth * column, self.tileHeight * row,
                         self.tileWidth, self.tileHeight,
                         animation)
    self.items:add(column, row, item)
end

function Level:setTile(column, row, sprite)
    local tile = newTile(self.tileWidth * column, self.tileHeight * row,
                         self.tileWidth, self.tileHeight,
                         sprite)
    self.tiles:add(column, row, tile)
end

function Level:getTile(column, row)
   return self.tiles:get(column, row)
end

function Level:removeTile(column, row)
    return self.tiles:removeTile(column, row)
end

function Level:setBackground(image)
    self.background = image
end

function Level:setCharacter(character, column, row)

    self.character = character
    self.character:calculateBoundingBox()

    
    -- nicht robust!
    local tile = self.tiles:get(column, row + 1)
    
    local x = tile.boundingBox.position.x
    local y = tile.boundingBox.position.y --- tile.boundingBox.height 

    print(x, y)
    
    self.character:setPosition(x,y)

    local w, h = self.character:getDimensions()
    self.character:translate(0, -h)
    

end

--[[
----------------------------------------------------
Scrolling
----------------------------------------------------]]
function Level:scroll(x, y)
    if self.grid:scroll(self.tiles, x, y) then
        self:scrollBackground(x / 2)
    end
end

function Level:scrollBackground(x)
    self.backgroundScroll.x = self.backgroundScroll.x + x
end

--[[
----------------------------------------------------
State management
----------------------------------------------------]]
function Level:start()
    -- nothing to do yet
end

function Level:pause()
    self.paused = true
    for item in self.items:iterator() do item:pause() end
    self.character:pause()
end

function Level:unpause()
    self.paused = false
    for item in self.items:iterator() do item:unpause() end
    self.character:unpause()
end

function Level:isPaused()
    return self.paused
end

--[[
----------------------------------------------------
Rendering
----------------------------------------------------]]
function Level:update(delta)
    self.particleSystem:update(delta)
end

function Level:drawBackground()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local imageWidth, imageHeight = self.background:getDimensions()

    love.graphics.push()
        local translation = self.backgroundScroll.x % screenWidth

        love.graphics.draw(self.background,  translation, 0, 0,  screenWidth / imageWidth, screenHeight / imageHeight)
        love.graphics.draw(self.background,  translation + screenWidth, 0, 0, screenWidth / imageWidth, screenHeight / imageHeight)
        love.graphics.draw(self.background,  translation - screenWidth, 0, 0, screenWidth / imageWidth, screenHeight / imageHeight)
    love.graphics.pop()
end

function Level:drawSnow()
    self.particleSystem:draw()
end

function Level:drawTiles()
    if config.ShowGrid then
        self.grid:drawGrid()
    end

    for tile in self.tiles:iterator() do
        tile:draw()
    end
end

function Level:drawItems()
    for item in self.items:iterator() do
        item:draw();
    end
end

function Level:draw()
    self:drawBackground()
    self:drawSnow()

    love.graphics.push("all")
        love.graphics.translate(self.grid.scrollOffset.x , self.grid.scrollOffset.y )

        self:drawTiles()
        self:drawItems()
        self.character:draw()

    love.graphics.pop()
end