require("ParticleSystem")
require("Grid")
require("HashMap2D")
require("Resources")

print("Res.Back:")
print(Resources)
print(Resources.backgroundImage)

local Level = {}

function createLevel(rows, columns)
    local level = {
        backgroundScroll = { x = 0, y = 0 },
        background = nil,
        grid = createGrid(rows, columns),
        items = newHashMap2D(),
        paused = false,
        particleSystem = createParticleSystem(2000, Resources.particleImage, 10),

        animations = {}
    }
    setmetatable(level, {__index = Level})

    level.character = Resources.animations[3]
    table.insert(level.animations, level.character)

    return level
end

--[[
----------------------------------------------------
Editing
----------------------------------------------------]]
function Level:setItem(column, row, animation)
    local tileWidth, tileHeight = self.grid:getTileDimensions()

    local item = newItem(tileWidth * column, tileHeight * row,
                         tileWidth, tileHeight,
                         animation)

    table.insert(self.animations, animation)
    self.items:add(column, row, item)
end

function Level:setTile(column, row, tile)
    self.grid:setTile(column, row, tile) -- TODO: Refactor
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
function Level:start()
    for _, animation in pairs(self.animations) do
        animation:play()
    end
end

function Level:pause()
    self.paused = true
    for _, animation in pairs(self.animations) do
        animation:pause()
    end
end

function Level:unpause()
    self.paused = false
    for _, animation in pairs(self.animations) do
        animation:unpause()
    end
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
    love.graphics.push("all")
        love.graphics.translate(self.grid.scrollOffset.x , self.grid.scrollOffset.y) -- TODO: refactor

        for item in self.items:iterator() do
            item:draw();
        end

    love.graphics.pop()
end

function Level:drawCharacter() -- TODO: refactor function
    love.graphics.push("all")
        love.graphics.translate(self.grid.scrollOffset.x , self.grid.scrollOffset.y )
        self.character:draw(-1500, 315, 450, 400)
    love.graphics.pop()
end

function Level:draw()
    self:drawBackground()
    self:drawSnow()
    self:drawTiles()
    self:drawItems()
    self:drawCharacter()
end