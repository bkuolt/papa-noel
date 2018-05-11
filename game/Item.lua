require("BoundingBox")

local Item = {}

function newItem(
    --[[ x, y, width, height, --]]animation, onCollect)
    local item = {}
    setmetatable(item, {__index = Item})

    item.animation = animation
    item.onCollect = onCollect
    item.boundingBox = newBoundingBox(x, y, width, height)

    return item
end

function Item:setPosition(x, y)
    self.boundingBox.position.x = x;
    self.boundingBox.position.y = y;
end

function Item:setSize(width, height)
    self.boundingBox.width = width;
    self.boundingBox.height = height;
end

function Item:draw()
    self.animation:draw(self.boundingBox.position.x, self.boundingBox.position.y,
                        self.boundingBox.width, self.boundingBox.height)
    self.boundingBox:draw()
end

function Item:getAnimation() -- TODO?
    return self.animation
end
