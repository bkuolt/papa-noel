BoundingBox = require("BoundingBox")
Config = require("conf")

--[[
----------------------------------------------------
GameObject
----------------------------------------------------
]]
GameObject = {}

-- TODO: Implement position, width, and height relative to margin
function newGameObject(x, y, width, height, animation)
    local gameObject = {
        position = {
            x = x or 0,
            y = y or 0
        },
        width = width or 0,
        height = height or 0,
        animation = animation,
        animations = {}
    }
    setmetatable(gameObject, { __index = GameObject })

    if animation and animation.play then
        animation:play()
    end

    gameObject:calculateBoundingBox()

    return gameObject
end

function GameObject:getDimensions()
    return self.boundingBox:getDimensions()
end

function GameObject:getPosition()
    return self.position.x, self.position.y
end

--[[
----------------------------------------------------
Animation Management
----------------------------------------------------
]]
function GameObject:addAnimation(name, animation)
    assert(name and animation, "Invalid animation name or object")
    self.animations[name] = animation
end

function GameObject:setAnimation(name)
    assert(self.animations and self.animations[name] ~= nil, "Unknown animation: " .. tostring(name))
    self.animation = self.animations[name]
    self.currentAnimation = self.animations[name]
    if self.animation.play then
        self.animation:play()
    end
end

--[[
----------------------------------------------------
Transformations & Physics
----------------------------------------------------
]]
function GameObject:translate(x, y)
    self.position.x = self.position.x + x
    self.position.y = self.position.y + y
    if self.boundingBox then
        self.boundingBox.position.x = self.boundingBox.position.x + x
        self.boundingBox.position.y = self.boundingBox.position.y + y
    end
end

function GameObject:calculateBoundingBox()
    local boundingBox
    local width, height

    if self.animation.getFrames then
        boundingBox = BoundingBox.createFromAnimation(self.animation)
        local frames = self.animation:getFrames()
        if #frames > 0 then
            width, height = frames[1]:getDimensions()
        else
            width, height = self.width, self.height
        end
    else
        boundingBox = BoundingBox.createFromSprite(self.animation)
        width, height = self.animation:getDimensions()
    end

    -- Scale bounding box to the specified size
    local scale = {
        x = width > 0 and (self.width / width) or 1,
        y = height > 0 and (self.height / height) or 1
    }

    boundingBox.width = boundingBox.width * scale.x
    boundingBox.height = boundingBox.height * scale.y
    boundingBox.position.x = boundingBox.position.x * scale.x
    boundingBox.position.y = boundingBox.position.y * scale.y

    -- Position bounding box
    boundingBox.position.x = self.position.x + boundingBox.position.x
    boundingBox.position.y = self.position.y + boundingBox.position.y

    self.boundingBox = boundingBox
end

function GameObject:setPosition(x, y)
    local offset = {
        x = x - self.position.x,
        y = y - self.position.y
    }

    -- Calculate margins here
    local margin = {
        x = self.boundingBox.position.x - self.position.x,
        y = self.boundingBox.position.y - self.position.y
    }

    offset.x = offset.x - margin.x
    offset.y = offset.y - margin.y

    self:translate(offset.x, offset.y)
end

function GameObject:draw()
    if self.animation and self.animation.draw then
        self.animation:draw(self.position.x, self.position.y, self.width, self.height)
    end

    if Config.ShowBoundingBoxes then
        -- Draws image bounding box
        love.graphics.push("all")
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.rectangle("line", self.position.x, self.position.y, self.width, self.height)
        love.graphics.pop()

        if self.boundingBox then
            self.boundingBox:draw()
        end
    end
end

function GameObject:pause()
    if self.animation and self.animation.pause then
        self.animation:pause()
    end
end

function GameObject:unpause()
    if self.animation and self.animation.unpause then
        self.animation:unpause()
    end
end

function GameObject:isPaused()
    if self.animation and self.animation.isPaused then
        return self.animation:isPaused()
    end
    return false
end