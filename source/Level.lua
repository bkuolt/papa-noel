require("ParticleSystem")
require("Grid")
require("HashMap2D")
require("Character")
require("Tile")
Resources = require("Resources")

--[[
----------------------------------------------------
Level
----------------------------------------------------
]]
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
        particleSystem = createParticleSystem(2000, Resources.images.snowflake, 10)
    }
    setmetatable(level, { __index = Level })

    level.tileWidth, level.tileHeight = level.grid:getTileDimensions()
    return level
end

--[[
----------------------------------------------------
Level Content Creation & Retrieval
----------------------------------------------------
]]
function Level:setItem(column, row, animation)
    local item = newItem(
        self.tileWidth * column, self.tileHeight * row,
        self.tileWidth, self.tileHeight,
        animation
    )
    self.items:add(column, row, item)
end

function Level:setTile(column, row, sprite)
    local tile = newTile(
        self.tileWidth * column, self.tileHeight * row,
        self.tileWidth, self.tileHeight,
        sprite
    )
    self.tiles:add(column, row, tile)
end

function Level:getTile(column, row)
    return self.tiles:get(column, row)
end

function Level:removeTile(column, row)
    return self.tiles:remove(column, row)
end

function Level:setBackground(image)
    self.background = image
end

function Level:setCharacter(column, row)
    self.character = newCharacter(
        -1500, 315,
        450, 400, -- width, height
        Resources.animations.character["Idle"]
    )

    self.character:calculateBoundingBox()

    local tile = self.tiles:get(column, row + 1)
    if tile and tile.boundingBox then
        local x = tile.boundingBox.position.x
        local y = tile.boundingBox.position.y

        self.character:setPosition(x, y)

        local _, height = self.character:getDimensions()
        self.character:translate(0, -height)
    end
end

--[[
----------------------------------------------------
Scrolling
----------------------------------------------------
]]
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
State Management
----------------------------------------------------
]]
function Level:start()
    -- Nothing to do yet
end

function Level:pause()
    self.paused = true
    for item in self.items:iterator() do
        item:pause()
    end
    if self.character then
        self.character:pause()
    end
end

function Level:unpause()
    self.paused = false
    for item in self.items:iterator() do
        item:unpause()
    end
    if self.character then
        self.character:unpause()
    end
end

function Level:isPaused()
    return self.paused
end

--[[
----------------------------------------------------
Rendering
----------------------------------------------------
]]
function Level:update(delta)
    self.particleSystem:update(delta)
end

function Level:drawBackground()
    if not self.background then
        return
    end

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local imageWidth, imageHeight = self.background:getDimensions()

    love.graphics.push()
        local translation = self.backgroundScroll.x % screenWidth
        love.graphics.draw(self.background, translation, 0, 0, screenWidth / imageWidth, screenHeight / imageHeight)
        love.graphics.draw(self.background, translation + screenWidth, 0, 0, screenWidth / imageWidth, screenHeight / imageHeight)
        love.graphics.draw(self.background, translation - screenWidth, 0, 0, screenWidth / imageWidth, screenHeight / imageHeight)
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
        item:draw()
    end
end

function Level:draw()
    self:drawBackground()
    self:drawSnow()

    love.graphics.push("all")
        love.graphics.translate(self.grid.scrollOffset.x, self.grid.scrollOffset.y)

        self:drawTiles()
        self:drawItems()
        if self.character then
            self.character:draw()
        end

    love.graphics.pop()
end