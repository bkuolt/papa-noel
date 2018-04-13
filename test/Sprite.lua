--[[
--------------------------------------------------------
Sprite
--------------------------------------------------------]]
local Sprite = {}

function newSprite(image, quad)
    local imageWidth, imageHeight = image:getDimensions()
    assert(imageWidth and imageHeight, "invalid image dimensions")

    local sprite = {
        image = image,
        quad = quad
    }

    setmetatable(sprite, {__index = Sprite })
    return sprite
end

function Sprite:getImage() -- TODO: remove function
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

function newSpriteSheet(image, columns, rows)
    local spriteSheet = {}

    spriteSheet.rows = rows 
    spriteSheet.columns = columns
    spriteSheet.image = image
    setmetatable(spriteSheet, {__index = SpriteSheet})

    return spriteSheet
end

function SpriteSheet:createQuad(column, row)
    local imageWidth, imageHeight = self.image:getDimensions()
    local cellWidth, cellHeight = imageWidth / self.columns, imageHeight / self.rows
    return love.graphics.newQuad(column * cellWidth, row * cellHeight, cellWidth, cellHeight, self.image:getDimensions())
end

function SpriteSheet:getIndices(index)
    return index % self.columns, 
           math.floor(index / (self.rows * self.columns))
end

function SpriteSheet:getSprite(index)
    return newSprite(self.image, self:createQuad(self:getIndices(index)))
end

function SpriteSheet:createAnimation(index, frameCount, fps)
    local animation = newAnimation()
    animation:setFPS(fps)

    for i = 0, frameCount - 1 do
        animation:addFrame(self:getSprite(index + i))
    end

    return animation
end