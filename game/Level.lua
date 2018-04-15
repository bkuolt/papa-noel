require("ParticleSystem")
require("Grid")
require("HashMap2D")

local Level = {}

function createLevel(rows, columns)
    local level = {
        backgroundScroll = { x = 0, y = 0 },
        background = nil,
        grid = createGrid(rows, columns),
        items = newHashMap2D(),
        paused = false,
        particleSystem = createParticleSystem(2000, Resources.particleImage ,10)
    }
    setmetatable(level, {__index = Level})

    return level
end

--[[
----------------------------------------------------
Editing
----------------------------------------------------]]
function Level:setItem(column, row, item)
    self.items:add(column, row, item)
    item:getAnimation():play()
end

function Level:setTile(column, row, tile)
    self.grid:setTile(column, row, tile)
end

function Level:getTile(column, row)
    return self.grid:getTile(column, row)
end

function Level:removeTile(column, row)
    return self.grid:removeTile(column, row)
end

function Level:setBackground(image)
    self.background = image
end

function Level:scroll(x, y)
    if self.grid:scroll(x, y) then 
        self:scrollBackground(x / 2)
    end
end

function Level:scrollBackground(x)
    self.backgroundScroll.x = self.backgroundScroll.x + x
end

--[[
----------------------------------------------------
Pause/Unpause
----------------------------------------------------]]
function Level:pause()
    self.paused = true

    for item, x, y in self.items:iterator() do
        item:getAnimation():pause()
    end

    self.character:pause()
end

function Level:unpause()
    self.paused = false

    for item, x, y in self.items:iterator() do
        item:getAnimation():unpause()
    end

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
    self.grid:draw()
end

function Level:drawItems()
    local tileWidth, tileHeight = self.grid:getTileDimensions()

    love.graphics.push("all")
         love.graphics.translate(self.grid.scrollOffset.x , self.grid.scrollOffset.y) -- TODO: refactor
  
        for item, x, y in self.items:iterator() do
            item:getAnimation():draw(x * tileWidth, y * tileHeight, tileWidth, tileHeight)
        end
    love.graphics.pop()
end

function Level:drawCharacter() -- TODO: refactor function
    love.graphics.push("all")
        love.graphics.translate(self.grid.scrollOffset.x , self.grid.scrollOffset.y )
        Resources.animations[3]:draw(-1500, 315, 450, 400)
    love.graphics.pop()
end

function Level:draw()
    self:drawBackground()
    self:drawSnow()
    self:drawTiles()
    self:drawItems()
    self:drawCharacter()
end