--[[
----------------------------------------------------
BoundingBox
----------------------------------------------------
]]
local BoundingBox = {}

function newBoundingBox(x, y, width, height)
    local boundingBox = {
        position = {
            x = x or 0,
            y = y or 0
        },
        width = width or 0,
        height = height or 0
    }
    setmetatable(boundingBox, { __index = BoundingBox })
    return boundingBox
end

function BoundingBox:doesCollide(other)
    if not other or not other.position then
        return false
    end

    return self.position.x < other.position.x + other.width and
           self.position.x + self.width > other.position.x and
           self.position.y < other.position.y + other.height and
           self.position.y + self.height > other.position.y
end

function BoundingBox:getDimensions()
    return self.width, self.height
end

function BoundingBox:getPosition()
    return self.position.x, self.position.y
end

function BoundingBox:draw()
    love.graphics.rectangle("line", self.position.x, self.position.y, self.width, self.height)
end

--[[
----------------------------------------------------
Helper
----------------------------------------------------
]]
local function isEmptyPixel(sprite, x, y)
    local _, _, _, a = sprite:getPixel(x, y)
    return a == 0 -- Alpha channel check
end

local function isEmptyColumn(sprite, x)
    local _, height = sprite:getDimensions()

    for y = 0, height - 1 do
        if not isEmptyPixel(sprite, x, y) then
            return false
        end
    end
    return true
end

local function isEmptyRow(sprite, y)
    local width, _ = sprite:getDimensions()

    for x = 0, width - 1 do
        if not isEmptyPixel(sprite, x, y) then
            return false
        end
    end
    return true
end

local function calculateOffsets(sprite)
    local width, height = sprite:getDimensions()

    local min = { x = 0, y = 0 }
    local max = { x = width - 1, y = height - 1 }

    while min.x < width and isEmptyColumn(sprite, min.x) do
        min.x = min.x + 1
    end

    while max.x >= min.x and isEmptyColumn(sprite, max.x) do
        max.x = max.x - 1
    end

    while min.y < height and isEmptyRow(sprite, min.y) do
        min.y = min.y + 1
    end

    while max.y > min.y and isEmptyRow(sprite, max.y) do
        max.y = max.y - 1
    end

    return min, max
end

function BoundingBox.createFromSprite(sprite)
    local min, max = calculateOffsets(sprite)

    return newBoundingBox(
        min.x, min.y,
        math.max(0, max.x - min.x),
        math.max(0, max.y - min.y)
    )
end

function BoundingBox.createFromAnimation(animation)
    local boundingBoxes = {}

    -- Calculate bounding box for each frame
    for _, frame in pairs(animation:getFrames()) do
        table.insert(boundingBoxes, BoundingBox.createFromSprite(frame))
    end

    -- Calculate bounding box containing all frames
    local max = { x = 0, y = 0 }
    local min = { x = math.huge, y = math.huge }

    for _, box in ipairs(boundingBoxes) do
        max.x = math.max(max.x, box.position.x + box.width)
        max.y = math.max(max.y, box.position.y + box.height)

        min.x = math.min(min.x, box.position.x)
        min.y = math.min(min.y, box.position.y)
    end

    return newBoundingBox(
        min.x, min.y,
        math.max(0, max.x - min.x),
        math.max(0, max.y - min.y)
    )
end

return BoundingBox