require("GameObject")

--[[
----------------------------------------------------
Tile
----------------------------------------------------
]]
local Tile = {}
setmetatable(Tile, { __index = GameObject })

function newTile(x, y, width, height, animation)
    local tile = newGameObject(x, y, width, height, animation)
    setmetatable(tile, { __index = Tile })
    return tile
end