local Tile = {}

function newTile(sprite)
    local tile = {}
    setmetatable(tile, {__index = Tile})

    item.sprite = sprite
    return tile
end

-- TODO