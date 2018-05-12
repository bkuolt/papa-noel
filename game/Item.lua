require("BoundingBox")

local Item = {}

function newItem(x, y, width, height, animation, onCollect)
    assert(x and y and width > 0 and height > 0 and animation, "One or more item properties are invalid")

    local item = {}
    setmetatable(item, {__index = Item})

    item.animation = animation
    item.onCollect = onCollect
    item.boundingBox = newBoundingBox(x, y, width, height)

    return item
end

function Item:draw()
    self.animation:draw(self.boundingBox.position.x, self.boundingBox.position.y,
                        self.boundingBox.width, self.boundingBox.height)
    self.boundingBox:draw()
end