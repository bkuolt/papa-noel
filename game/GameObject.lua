require("BoundingBox")
Config = require("conf")

--[[
--------------------------------------------------------
Animation
--------------------------------------------------------]]
GameObject = {}

function newGameObject(x, y, width, height, animation)
    local gameObject = {}
    setmetatable(gameObject, {__index = GameObject })

    gameObject.boundingBox = newBoundingBox(x, y, width, height)

    gameObject.animation = animation
    if animation.play then
        animation:play()
    end

    return gameObject
end

function GameObject:draw()
    self.animation:draw(self.boundingBox.position.x, self.boundingBox.position.y,
                        self.boundingBox.width, self.boundingBox.height)

    if Config.ShowBoundingBoxes then
        self.boundingBox:draw()
    end
end

function GameObject:pause()
    if self.animation.play then self.animation:pause() end
end

function GameObject:unpause()
    if self.animation.play then self.animation:unpause() end
end

function GameObject:isPaused()
    if self.animation.isPaused then self.animation:isPaused() end
end