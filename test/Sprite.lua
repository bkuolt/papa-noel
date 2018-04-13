--[[
--------------------------------------------------------
Sprite
--------------------------------------------------------]]
local Sprite = {}

function newSprite(image, quad)
    local imageWidth, imageHeight = image:getDimensions()
    assert(imageWidth and imageHeight, "invalid image dimensions")

    local sprite = {}
    setmetatable(sprite, {__index = Sprite })
    sprite.image = image
    sprite.quad = quad

    return sprite
end

function Sprite:getImage() -- TODO: deprecated -> remove function
    return self.image
end

function Sprite:getScaleFactor(width, height)
    local imageWidth, imageHeight = self.image:getDimensions()
    return { x = width / imageWidth, 
             y = height / imageHeight }
end

function Sprite:draw(x, y, width, height)
    assert(x and y, "invalid draw position")
    assert(width and height and width > 0 and height > 0, "invalid draw size")

    local scale = self:getScaleFactor(width, height)

    if self.quad then
        love.graphics.draw(self.image, self.quad, x, y, 0, scale.x, scale.y)
    else
        love.graphics.draw(self.image, x, y, 0, scale.x, scale.y)
    end
end

--[[
--------------------------------------------------------
SpriteSheet
--------------------------------------------------------]]
local SpriteSheet = {}

function newSpriteSheet(images)
    assert(images, "invalid table")
    -- TODO: assure that all images have the same dimensions

    local spriteSheet = {}
    setmetatable(spriteSheet, {__index = SpriteSheet})

    spriteSheet.cellWidth, spriteSheet.cellHeight = images[1]:getDimensions()
    spriteSheet.columns, spriteSheet.rows = spriteSheet:calculateGridSize(#images, spriteSheet.cellWidth, spriteSheet.cellHeight)

    spriteSheet.canvas = love.graphics.newCanvas(spriteSheet.columns * spriteSheet.cellWidth, spriteSheet.rows * spriteSheet.imageHeight)
    spriteSheet:drawToCanvas(images)

    return spriteSheet
end

function SpriteSheet:calculateGridSize(imageCount, imageWidth, imageHeight)
    local maximumTextureSize = love.graphics.getSystemLimits().texturesize
  
    local maxColumnCount = math.floor(maximumTextureSize / imageWidth)
    local maxRowCount = math.floor(maximumTextureSize / imageHeight) 
    assert(imageCount < maxRowCount * maxColumnCount, "this system does not support large enough textures to create the spritesheet")

    return math.min(maxColumnCount, imageCount), -- column count
           math.ceil(imageCount / columns)       -- row count
end

function SpriteSheet:drawToCanvas(images)
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0.0, 0.0, 0.0, 0.0)
    
    local column, row
    for i = 1, #images do
        column, row = self:getIndices(i)
        love.graphics.draw(images[i], column * self.cellWidth, row * self.cellHeight)
    end

    love.graphics.setCanvas()
end

function SpriteSheet:createQuad(column, row)
    return love.graphics.newQuad(column * self.cellWidth, row * self.cellHeight, self.cellWidth, self.cellHeight, self.canvas:getDimensions())
end

function SpriteSheet:getIndices(index)
    return index % self.columns,
           math.floor(index / (self.rows * self.columns))
end

function SpriteSheet:getSprite(index)
    return newSprite(self.canvas, self:createQuad(self:getIndices(index)))
end

-- TODO: move to Animation.lua
--[[
function SpriteSheet:createAnimation(index, frameCount, fps)
    local animation = newAnimation()
    animation:setFPS(fps)

    for i = 0, frameCount - 1 do
        animation:addFrame(self:getSprite(index + i))
    end

    return animation
end
--]]