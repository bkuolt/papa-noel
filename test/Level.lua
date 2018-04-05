require("ParticleSystem")
require("Grid")

--[[
----------------------------------------------------
 Level
----------------------------------------------------]]
local Level = {}

function createLevel(rows, columns)


    local level = {
        backgroundScroll = { x = 0, y = 0 },
        background = nil,
        grid = createGrid(rows, columns)
    }
    setmetatable(level, {__index = Level})
    level.particleSystem = createParticleSystem(1000, love.graphics.newImage("a.png") ,16)

    return level
end

--add set tile

function Level:setTile(x, y, tile)
    self.grid:addTile(x, y, tile)
end

function Level:getTile(x, y)
    return self.grid:getTile(x, y)
end

function Level:removeTile(x, y)
    return self.grid:removeTile(x, y)
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

function Level:draw()
    self:drawBackground()
    self:drawSnow()
    self:drawTiles()
end

function Level:update(delta)
    self.particleSystem:update(delta)
end