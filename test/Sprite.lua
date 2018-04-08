--[[
--------------------------------------------------------
Renderable
--------------------------------------------------------]]
local Sprite = {}

function newSprite(image, quad)
    local sprite = {
        image = image,
        quad = quad,
        scale = { x = 1.0, y = 1.0 },
        position = { x = 0, y = 0 }
    }

    local imageWidth, imageHeight = sprite.image:getDimensions()
    assert(imageWidth ~= 0 and imageHeight ~= 0, "invalid image dimensions")
    
    setmetatable(sprite, {__index = Sprite })
    return sprite
end

function Sprite:setPosition(x, y)
    self.position.x = x
    self.position.y = y
end

function Sprite:setSize(width, height)
    assert(width ~= nil and height ~= nil and width > 0 and height > 0, "invalid sprite size")

    local imageWidth, imageHeight = self.image:getDimensions()
    self.scale.x = width / imageWidth
    self.scale.y = height / imageHeight
end

function Sprite:draw()
    if self.quad then
        love.graphics.draw(self.image, self.quad, self.position.x, self.position.y, 0, self.scale.x, self.scale.y)
    else
        love.graphics.draw(self.image, self.position.x, self.position.y, 0, self.scale.x, self.scale.y)
    end
end

function Sprite:getPosition()
    return self.position.x, self.position.y
end

function Sprite:getDimensions()
    local imageWidth, imageHeight = self.image:getDimensions()
    return imageWidth * self.scale.x, imageHeight * self.scale.y
end

function Sprite:getImage()
    return self.image
end
