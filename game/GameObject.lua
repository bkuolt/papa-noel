BoundingBox = require("BoundingBox")
Config = require("conf")

--[[
--------------------------------------------------------
Animation
--------------------------------------------------------]]
GameObject = {}

function newGameObject(x, y, width, height, animation)
    local gameObject = {}
    setmetatable(gameObject, {__index = GameObject })

    gameObject.position = {}
    gameObject.position.x = x;
    gameObject.position.y = y;

    gameObject.width = width
    gameObject.height = height

    gameObject.margin = {x = 0, y = 0}


    gameObject.boundingBox = newBoundingBox(x, y, width, height)

    gameObject.animation = animation
    if animation.play then
        animation:play()
    end

    return gameObject
end

function GameObject:getDimensions()
    return self.boundingBox:getDimensions()
end

function GameObject:getPosition()
    return self.position
end

function GameObject:translate(x, y)
    self.position.x = self.position.x + x
    self.position.y = self.position.y + y
    self.boundingBox.position.x = self.boundingBox.position.x + x
    self.boundingBox.position.y = self.boundingBox.position.y + y
end


function GameObject:calculateBoundingBox()
    local boundingBox = BoundingBox.createFromAnimation(self.animation)

    -- scale box to the desired size
    local w,h = self.animation:getFrames()[1]:getDimensions()
    boundingBox.width = boundingBox.width * (self.width / w)
    boundingBox.height = boundingBox.height * (self.height) / h
    boundingBox.position.x = boundingBox.position.x * (self.width / w)
    boundingBox.position.y = boundingBox.position.y  * (self.height / h)

    -- calculate margins
    self.margin.x = boundingBox.position.x
    self.margin.y = boundingBox.position.y
    print(self.margin.x, self.margin.y)

    -- position bounding box globally
    boundingBox.position.x = self.position.x + boundingBox.position.x
    boundingBox.position.y = self.position.y + boundingBox.position.y

    self.boundingBox = boundingBox
end

function GameObject:setPosition(x, y)
    local offset = {}
    offset.x = x -self.position.x
    offset.y = y -self.position.y

    offset.x = offset.x - self.margin.x
    offset.y = offset.y - self.margin.y

    self:translate(offset.x, offset.y)
end

function GameObject:draw()
    self.animation:draw(self.position.x, self.position.y,
                        self.width, self.height)

    if Config.ShowBoundingBoxes then
        love.graphics.push("all")
            love.graphics.setColor(1,0,0)
            love.graphics.rectangle("line", self.position.x, self.position.y, self.width, self.height)
         --   love.graphics.setColor(1,1,0)
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