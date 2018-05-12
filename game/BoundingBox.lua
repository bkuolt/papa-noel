
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

-- TODO: create bounding box from sprite