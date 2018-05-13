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

        animations = {},
        tiles = newHashMap2D()
    }
    setmetatable(level, {__index = Level})


    level.character = Resources.animations[3]                          -- Refactor
    table.insert(level.animations, level.character)                    -- Refactor
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

    table.insert(self.animations, animation)
    self.items:add(column, row, item)
end

function Level:setTile(column, row, sprite)
    local tile = newItem(self.tileWidth * column, self.tileHeight * row,
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

function Level:drawCharacter() -- TODO: refactor function
    self.character:draw(-1500, 315, 450, 400)
end

function Level:draw()
    self:drawBackground()
    self:drawSnow()

    love.graphics.push("all")
        love.graphics.translate(self.grid.scrollOffset.x , self.grid.scrollOffset.y )

        self:drawTiles()
        self:drawItems()
        self:drawCharacter()

    love.graphics.pop()
end