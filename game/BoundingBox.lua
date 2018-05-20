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
--[[
local function isEmptyPixel(imageData, x, y)
    local r,g,b,a = imageData:getPixel(x, y)
    return a == 0 -- alpha channel
end

local function isEmptyColumn(imageData, x)
    for y = 0, imageData:getHeight() - 1 do
        if not isEmptyPixel(imageData, x, y) then 
            return false 
        end
    end
    return true
end

local function isEmptyRow(imageData, y)
    for x = 0, imageData:getWidth() - 1 do
        if not isEmptyPixel(imageData, x, y) then 
            return false 
        end
    end
    return true
end

local function calculateOffsets(imageData) 
    local width, height = imageData:getDimensions()

    local min = {x = 0, y = 0}
    local max = {x = width - 1, y = height - 1}

    while min.x < width and isEmptyColumn(imageData, min.x) do  
        min.x = min.x + 1 
    end 

    while max.x >= min.x and isEmptyColumn(imageData, max.x) do 
        max.x = max.x - 1
    end

    while min.y < height and isEmptyRow(imageData, min.y) do 
        min.y = min.y + 1
    end

    while max.y > min.x and isEmptyRow(imageData, max.y) do 
        max.y = max.y - 1
    end

    return min, max
end

--]]


function BoundingBox.createFromSprite(sprite)
    --[[
    for y = 0, sprite:getHeight() do 
        for x = 0, sprite:getHeight() do 
    
     color in sprite:getPixelIterator() do
        -- TODO
    end
    --]]
end

function BoundingBox.createFromAnimation(animation)
    local boundingBoxes = {}

    -- calculate bounding box for each frame
    for frame in animation:getFrames() do
        table.insert(boundingBoxes, BoundingBox.createFromSprite(frame))
    end

    -- TODO: calculate the bounding box so that each bounding box is within
end

return BoundingBox