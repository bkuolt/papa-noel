--[[
--------------------------------------------------------
Sprite
--------------------------------------------------------]]
local Sprite = {}

function newSprite(spriteSheet, quad)
    local sprite = {}
    setmetatable(sprite, {__index = Sprite })

    local viewport = {}
    viewport.x, viewport.y, viewport.width, viewport.height = quad:getViewport()

    sprite.viewport = viewport
    sprite.spriteSheet = spriteSheet
    sprite.quad = quad

    return sprite
end

function Sprite:getTexture()
    return self.spriteSheet.canvas
end

function Sprite:getPixel(x, y)
    assert(x >= 0 and x < self.viewport.width and y >= 0 and y < self.viewport.height, "coordinates are out of bounce")
    return self.spriteSheet.imageData:getPixel(self.viewport.x + x, self.viewport.y + y)
end

function Sprite:getDimensions()
    return self.viewport.width, self.viewport.height
end

function Sprite:draw(x, y, width, height)
    assert(x and y, "invalid draw position")
    assert(width and height and width > 0 and height > 0, "invalid draw size")

    local scale = { x = width / self.viewport.width,
                    y = height / self.viewport.height }

    love.graphics.draw(self.spriteSheet.canvas, self.quad, x, y, 0, scale.x, scale.y)
end

--[[
--------------------------------------------------------
SpriteSheet
--------------------------------------------------------]]
local SpriteSheet = {}

function newSpriteSheet(images)
    assert(images, "invalid table")

    local spriteSheet = {}
    setmetatable(spriteSheet, {__index = SpriteSheet})

    spriteSheet.cellWidth, spriteSheet.cellHeight = images[1]:getDimensions()
    spriteSheet.columns, spriteSheet.rows = spriteSheet:calculateGridSize(#images, spriteSheet.cellWidth, spriteSheet.cellHeight)

    spriteSheet.canvas = love.graphics.newCanvas(spriteSheet.columns * spriteSheet.cellWidth, spriteSheet.rows * spriteSheet.cellHeight)
    spriteSheet:drawToCanvas(images)

    spriteSheet.sprites = spriteSheet:createSprites(#images)
    spriteSheet.imageData = spriteSheet.canvas:newImageData()

    return spriteSheet
end

function SpriteSheet:calculateGridSize(imageCount, imageWidth, imageHeight)
    local maximumTextureSize = love.graphics.getSystemLimits().texturesize

    local maxColumnCount = math.floor(maximumTextureSize / imageWidth)
    local maxRowCount = math.floor(maximumTextureSize / imageHeight)

    assert(imageCount < maxRowCount * maxColumnCount, "this system does not support large enough textures to create the spritesheet")

    return math.min(maxColumnCount, imageCount),  -- column count
           math.ceil(imageCount / maxColumnCount) -- row count
end

function SpriteSheet:drawToCanvas(images)
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0.0, 0.0, 0.0, 0.0)

    local column, row
    for i = 1, #images do
        column, row = self:getIndices(i - 1)

        local imageWidth, imageHeight = images[i]:getDimensions()
        love.graphics.draw(images[i], column * self.cellWidth, row * self.cellHeight, 0,
                           self.cellWidth / imageWidth, self.cellHeight / imageHeight --[[ assures that all images have the same dimensions --]])
    end

    love.graphics.setCanvas()
end

function SpriteSheet:getIndices(index)
    return index % self.columns,
           math.floor(index / (self.rows * self.columns))
end

function SpriteSheet:createQuad(index)
    local column, row = self:getIndices(index)
    return love.graphics.newQuad(column * self.cellWidth, row * self.cellHeight, self.cellWidth, self.cellHeight, self.canvas:getDimensions())
end

function SpriteSheet:createSprites(spriteCount)
    local sprites = {}

    for index = 1, spriteCount do
        sprites[index] = newSprite(self, self:createQuad(index - 1))
    end
    return sprites
end

function SpriteSheet:getSpriteCount()
    return #self.sprites
end

function SpriteSheet:getSprite(index)
    assert(index >= 1 and index <= self:getSpriteCount(), "invalid sprite index")
    return self.sprites[index]
end

function SpriteSheet:getIndex(sprite)
    for index = 1, self:getSpriteCount() do
        if self:getSprite(index) == sprite then
            return index
        end
    end
    return nil
end
