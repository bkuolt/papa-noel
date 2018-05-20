require("GameObject")

--[[
--------------------------------------------------------
Item
--------------------------------------------------------]]
local Item = {}
setmetatable(Item, {__index = GameObject})

function newItem(x, y, width, height, animation)
    local item = newGameObject(x, y, width, height, animation)
    setmetatable(item, {__index = Item})
    return item
end