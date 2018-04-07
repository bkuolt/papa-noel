--[[
--------------------------------------------------------
Renderable
--------------------------------------------------------]]
local Sprite = {}

function newSprite(filename)
    local sprite = {
        image = love.graphics.newImage(filename),
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
    love.graphics.draw(self.image, self.position.x, self.position.y, 0, self.scale.x, self.scale.y)
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

--[[
--------------------------------------------------------
Animation
--------------------------------------------------------]]
Animation = {}

local animationShader = love.graphics.newShader([[
        uniform sampler2D secondFrame;
        uniform float tweenFactor;

        vec4 effect(vec4 color, Image firstFrame, vec2 textureCoords, vec2 screenCoords)
        {
            vec4 texels[2];
            texels[0] = Texel(firstFrame, textureCoords);
            texels[1] = Texel(secondFrame, textureCoords);
            
            return texels[0] + (texels[1] - texels[0]) * tweenFactor;
        }
    ]])

function Animation.create()
    local animation = {
        flipped = false,
        running = false,
        paused = false,
        fps = 0,
        scale = {x = 1.0, y = 1.0},
        position = {x = 0, y = 0},
        frames = {}
    }

    local metaTable = {__index = Animation }
    setmetatable(animation, metaTable)
    return animation
end

function Animation:addFrame(sprite)
    assert(sprite ~= nil, "Invalid frame")
    self.frames[#self.frames + 1] = sprite
end

function Animation:setFPS(fps)
    assert(fps ~= nil and fps > 0, "Invalid frame rate")
    self.fps = fps
end

function Animation:play()
    self.running = true
    self.paused = false
    self.startTime = love.timer.getTime()
end

function Animation:pause()
    self.paused = true
    self.startTime = love.timer.getTime()
end

function Animation:unpause()
    -- TODO
end

function Animation:flip()
    self.flipped = not self.flipped
end

function Animation:setPosition(x, y)
    for sprite in pairs(self.frames) do 
        sprite:setPosition(x, y)
    end
end

function Animation:setSize(width, height)
    for index, sprite in pairs(self.frames) do 
        sprite:setSize(width, height)
    end
end

function Animation:isFlipped()
    return self.flipped
end

--[[
@return index of the current frame, index of the following frame, tween factor 
]]
function Animation:getCurrentFrames() -- TODO: handle pause
    local delta = love.timer.getTime() - self.startTime

    local currentFrameIndex, tweenFactor = math.modf(delta * self.fps)
    currentFrameIndex = currentFrameIndex % #self.frames
    local nextFrameIndex = (currentFrameIndex + 1) % #self.frames

    return self.frames[1 + currentFrameIndex], self.frames[1 + nextFrameIndex], tweenFactor
end

function Animation:draw()
    if not self.running then 
        return -- nothing to render
    end

    local currentFrame, nextFrame, tweenFactor = self:getCurrentFrames()
 
    love.graphics.push("all")
        love.graphics.setShader(animationShader)
        animationShader:send("secondFrame", nextFrame:getImage())
        animationShader:send("tweenFactor", tweenFactor)

        currentFrame:draw()
    love.graphics.pop()
end

--[[
--------------------------------------------------------
Helper
--------------------------------------------------------]]
function LoadAnimation(filename, frameCount, fps)
    local animation = Animation.create()

    for index = 1, frameCount do 
        local filename = string.format(filename, index)
        animation:addFrame(newSprite(filename))
    end

    animation:setFPS(fps)
    return animation
end

return Animation