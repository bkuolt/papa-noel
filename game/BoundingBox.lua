local BoundingBox = {}

function newBoundingBox(x, y, width, height)
    local boundingBox = {}
    setmetatable(boundingBox, {__index = BoundingBox})

    boundingBox.position = {}
    boundingBox.position.x = x
    boundingBox.position.y = y

    boundingBox.height = height
    boundingBox.width = width

    return boundingBox
end

function BoundingBox:doesCollide(boundingBox)
    return false -- TODO
end

function BoundingBox:getDimensions()
    return self.width, self.height
end

function BoundingBox:getPosition()
    return self.position.x, self.self.position.y
end

function BoundingBox:draw()
    love.graphics.rectangle("line", self.position.x, self.position.y, self.width, self.height)
end

--[[
----------------------------------------------------
Helper
----------------------------------------------------]]

local function isEmptyPixel(sprite, x, y)
    local r,g,b,a = sprite:getPixel(x, y)
    return a == 0 -- alpha channel
end

local function isEmptyColumn(sprite, x)
    local width, height = sprite:getDimensions()

    for y = 0, height - 1 do
        if not isEmptyPixel(sprite, x, y) then
            return false
        end
    end
    return true
end

local function isEmptyRow(sprite, y)
    local width, height = sprite:getDimensions()

    for x = 0, width - 1 do
        if not isEmptyPixel(sprite, x, y) then
            return false
        end
    end
    return true
end

local function calculateOffsets(sprite)
    local width, height = sprite:getDimensions()

    local min = {x = 0, y = 0}
    local max = {x = width - 1, y = height - 1}

    while min.x < width and isEmptyColumn(sprite, min.x) do  
        min.x = min.x + 1 
    end 

    while max.x >= min.x and isEmptyColumn(sprite, max.x) do 
        max.x = max.x - 1
    end

    while min.y < height and isEmptyRow(sprite, min.y) do 
        min.y = min.y + 1
    end

    while max.y > min.x and isEmptyRow(sprite, max.y) do 
        max.y = max.y - 1
    end


    return min, max
end


function BoundingBox.createFromSprite(sprite)

    local min, max = calculateOffsets(sprite)

    return newBoundingBox(min.x, min.y,
                          max.x - min.x, max.y - min.y)
end

function BoundingBox.createFromAnimation(animation)
    local boundingBoxes = {}

    local timestamp = love.timer.getTime()

    -- calculate bounding box for each frame
    for _, frame in pairs(animation:getFrames()) do
        table.insert(boundingBoxes, BoundingBox.createFromSprite(frame))
    end


    --calculate the bounding box so that each bounding box is within
    local max = {x = 0, y = 0}
    local min = {x = math.huge, y = math.huge}

    for _, box in pairs(boundingBoxes) do
        max.x = math.max(max.x, box.position.x + box.width)
        max.y = math.max(max.y, box.position.y + box.height)

        min.x = math.min(min.x, box.position.x)
        min.y = math.min(min.y, box.position.y)
    end

    print(string.format("Bounding box calculation %f seconds", love.timer.getTime() - timestamp))
    return newBoundingBox(min.x, min.y,
                          max.x - min.x, max.y - min.y)
end

return BoundingBox