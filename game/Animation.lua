require("Sprite")

--[[
--------------------------------------------------------
Animation
--------------------------------------------------------]]
local Animation = {}

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

function newAnimation(spritesheet, fps)
    assert(spritesheet, "invalid spritesheet")
    assert(fps > 0, "invalid frames per second count")

    local animation = {
        running = false,
        paused = false,
        duration = 0
    }

    local metaTable = {__index = Animation }
    setmetatable(animation, metaTable)

    animation.frames = animation:createFrames(spritesheet)
    animation.fps = fps

    return animation
end

function Animation:createFrames(spritesheet)
    local frames = {}
    for i = 1, spritesheet:getSpriteCount() do
        frames[i] = spritesheet:getSprite(i)
    end
    return frames
end

function Animation:getFrames()
    return self.frames
end

function Animation:play()
    self.running = true
    self.paused = false

    self.duration = 0
    self.lastTimestamp = love.timer.getTime()
end

function Animation:stop()
    self.running = false
    self.paused = false
end

function Animation:pause()
    if not self:isRunning() then
        return
    end

    self.paused = true
    self.duration = self.duration + (love.timer.getTime() - self.lastTimestamp)
end

function Animation:unpause()
    if not self:isPaused() then
        return
    end

    self.paused = false
    self.lastTimestamp = love.timer.getTime()
end

function Animation:isPaused()
    return self.paused
end

function Animation:isRunning()
    return self.running
end

function Animation:flip()
    self.flipped = not self.flipped
end

--[[
@return index of the current frame, index of the following frame and the tween factor
]]
function Animation:getCurrentFrames()
    if not self.paused then 
        self.duration = self.duration + (love.timer.getTime() - self.lastTimestamp)
        self.lastTimestamp = love.timer.getTime()
    end

    local currentFrameIndex, tweenFactor = math.modf(self.duration * self.fps)
    currentFrameIndex = currentFrameIndex % #self.frames
    local nextFrameIndex = (currentFrameIndex + 1) % #self.frames

    return self.frames[1 + currentFrameIndex], self.frames[1 + nextFrameIndex], tweenFactor
end

function Animation:draw(x, y, width, height)
    if not self.running then
        return -- nothing to render
    end

    local currentFrame, nextFrame, tweenFactor = self:getCurrentFrames()

    love.graphics.push("all")
        love.graphics.setShader(animationShader)
        animationShader:send("secondFrame", nextFrame:getTexture())
        animationShader:send("tweenFactor", tweenFactor)

        currentFrame:draw(x, y, width, height)
    love.graphics.pop()
end

--[[
--------------------------------------------------------
Helper
--------------------------------------------------------]]
function Animation.LoadAnimation(images, fps)
    local spriteSheet = newSpriteSheet(images)
    local animation = newAnimation(spriteSheet, fps)
    return animation
end

return Animation