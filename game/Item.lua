require("BoundingBox")

--[[
--------------------------------------------------------
Animation
--------------------------------------------------------]]
local GameObject = {}

function newGameObject(x, y, width, height, animation)
    local gameObject = {}
    setmetatable(gameObject, {__index = GameObject })

    gameObject.animation = animation
    gameObject.boundingBox = newBoundingBox(x, y, width, height)

    return gameObject
end

function GameObject:draw()
    self.animation:draw(self.boundingBox.position.x, self.boundingBox.position.y,
                        self.boundingBox.width, self.boundingBox.height)
    self.boundingBox:draw()
end

function GameObject:play()
    if self.animation.play then self.animation:play() end
end

function GameObject:pause()
    if self.animation.play then self.animation:pause() end
end

function GameObject:unpause()
    if self.animation.play then self.animation:unpause() end
end

--[[
--------------------------------------------------------
Item
--------------------------------------------------------]]
local Item = GameObject

function newItem(x, y, width, height, animation)
    local item = newGameObject(x, y, width, height, animation)
    setmetatable(item, {__index = Item})
    return item
end