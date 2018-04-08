require("test/Sprite")

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
    self:updateRunDuration(0)
end

function Animation:stop()
    self.running = false
    self.paused = false
end

function Animation:updateRunDuration(duration)
    if duration ~= nil then
        self.runDuration = 0
        self.lastTimestamp = love.timer.getTime()
    end
    if not self.paused then 
        self.runDuration = self.runDuration + (love.timer.getTime() - self.lastTimestamp)
        self.lastTimestamp = love.timer.getTime()
    end
end

function Animation:pause()
    if not self:isRunning() then
        self:play()
    end

    self:updateRunDuration()
    self.paused = true
end

function Animation:unpause()
    if not self:isPaused() then
        return
    end

    self.paused = false
    self:updateRunDuration()
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

--[[
@return index of the current frame, index of the following frame, tween factor 
]]
function Animation:getCurrentFrames() -- TODO: handle pause
    self:updateRunDuration()

    local currentFrameIndex, tweenFactor = math.modf(self.runDuration * self.fps)
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
        animation:addFrame(newSprite(love.graphics.newImage(filename)))
    end

    animation:setFPS(fps)
    return animation
end


-- start is 1
function LoadCoin(frameCount, fps)
    local animation = Animation.create()
    local image = love.graphics.newImage("test/coin.png")
    
    local width  = image:getWidth() / frameCount
    local height = image:getHeight()
    

    for index = 1, frameCount do
  
        local quad = love.graphics.newQuad((index-1) * width, 0, width, height,  image:getDimensions()) 
  
        animation:addFrame(newSprite(image, quad))
    end

    animation:setFPS(fps)
    return animation
end

return Animation
