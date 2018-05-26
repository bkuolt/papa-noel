BoundingBox = require("BoundingBox")
Config = require("conf")

--[[
--------------------------------------------------------
Animation
--------------------------------------------------------]]
GameObject = {}

-- TODO position,width,height relativ to margin implementieren
function newGameObject(x, y, width, height, animation)
    local gameObject = {}
    setmetatable(gameObject, {__index = GameObject })

    gameObject.position = {}
    gameObject.position.x = x;
    gameObject.position.y = y;

    gameObject.width = width
    gameObject.height = height

    gameObject.animation = animation
    if animation.play then
        animation:play()
    end

     gameObject:calculateBoundingBox()

    return gameObject
end

function GameObject:getDimensions() -- not used yet 
    return self.boundingBox:getDimensions()
end

function GameObject:getPosition()
    return self.position -- TODO
end

-------------------------------------------------------------------------------
function GameObject:addAnimation(name, animation)
    assert(name and animation, "invalid animation name or object")
    self.animations[name] = animation
end

function GameObject:setAnimation(name)
    assert(self.animations[name] ~= nil, "unknown animation")
    self.currentAnimation = self.animations[name]
end
-------------------------------------------------------------------------------

function GameObject:translate(x, y)
    self.position.x = self.position.x + x
    self.position.y = self.position.y + y
    self.boundingBox.position.x = self.boundingBox.position.x + x
    self.boundingBox.position.y = self.boundingBox.position.y + y
end

function GameObject:calculateBoundingBox()
    local boundingBox
    local width, height

    if self.animation.getFrames then
         boundingBox = BoundingBox.createFromAnimation(self.animation)
         width, height = self.animation:getFrames()[1]:getDimensions()
    else
        boundingBox = BoundingBox.createFromSprite(self.animation)
        width, height = self.animation:getDimensions()
    end

    -- scale bounding box to the specified size
    local scale = {
        x = self.width / width,
        y = self.height / height
    }

    boundingBox.width = boundingBox.width * scale.x
    boundingBox.height = boundingBox.height * scale.y
    boundingBox.position.x = boundingBox.position.x * scale.x
    boundingBox.position.y = boundingBox.position.y  * scale.y

    -- position bounding box
    boundingBox.position.x = self.position.x + boundingBox.position.x
    boundingBox.position.y = self.position.y + boundingBox.position.y

    self.boundingBox = boundingBox
end

function GameObject:setPosition(x, y)
    local offset = {}
    offset.x = x -self.position.x
    offset.y = y -self.position.y

    -- calculate margins here
    local margin = {}
    margin.x = self.boundingBox.position.x - self.position.x
    margin.y = self.boundingBox.position.y - self.position.y

    offset.x = offset.x - margin.x
    offset.y = offset.y - margin.y

    self:translate(offset.x, offset.y)
end

function GameObject:draw()
    self.animation:draw(self.position.x, self.position.y, self.width, self.height)

    if Config.ShowBoundingBoxes then
        -- draws image bounding box
        love.graphics.push("all")
            love.graphics.setColor(1,0,0)
            love.graphics.rectangle("line", self.position.x, self.position.y, self.width, self.height)
        love.graphics.pop()

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