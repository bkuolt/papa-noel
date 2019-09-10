--[[
----------------------------------------------------
TileSelector
----------------------------------------------------]]
local TileSelector = {
    currentSpriteIndex = 1
}

function TileSelector.setCurrentTile(sprite)
    assert(sprite, "invalid sprite")
    TileSelector.currentSpriteIndex = Resources.tileMap:getIndex(sprite) 
end

function TileSelector.getCurrentTile()
    return tileMap:getSprite(TileSelector.currentSpriteIndex)
end

function TileSelector.scroll(tile, scrollOffset) -- TODO: something is broken
    assert(tile, "invalid tile")
    assert(scrollOffset, "invalid tile")

    TileSelector.currentSpriteIndex = (TileSelector.currentSpriteIndex + math.abs(scrollOffset)) % Resources.tileMap:getSpriteCount()
    TileSelector.currentSpriteIndex = math.max(1, TileSelector.currentSpriteIndex)

    tile.sprite = TileSelector.getCurrentTile()
end

--[[
----------------------------------------------------
Level Editor
----------------------------------------------------]]
--[[
@brief Creates a new tile on the clicked cell in the grid or scrolls the current tiles image
@param x,y mouse coordinates in pixels
@param button currently pressed mouse button (Love2D values)
]]
local LevelEditor = {}

function LevelEditor.onClick(x, y, button)
    local column, row = level.grid:getTileIndices(x, y)

    if button == 1 then      -- (left click) set or scroll tile image
        local tile = level:getTile(column, row)
        if tile == nil then
             level:setTile(column, row, TileSelector.getCurrentTile())
        else 
            TileSelector.setCurrentTile(tile.sprite)
            TileSelector.scroll(tile, 1)
        end

        love.mouse.setCursor(love.mouse.getSystemCursor("sizens"))
    elseif button == 2 then  -- (right click) remove tile
        level:removeTile(column, row)
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    end
end

--[[
@brief Scrolls the image, if existent, of the current grid cell 
@param x,y mouse coordinates in pixels
@param scrollOffset mouse wheel scroll units
]]
function LevelEditor.onMouseWheelMoved(x, y, scrollOffset)
    local column, row = level.grid:getTileIndices(x, y)

    local tile = level:getTile(column, row)
    if tile == nil then 
        return -- no tile to scroll image for 
    end

    TileSelector.setCurrentTile(tile.sprite)
    TileSelector.scroll(tile, scrollOffset)
end

function LevelEditor.onMouseMove(x, y, dx, dy)
    if love.mouse.isDown(2) then -- left mouse button pressed and mouse moved
        level:scroll(dx, dy)
        love.mouse.setCursor(love.mouse.getSystemCursor("crosshair"))
    else
        local column, row = level.grid:getTileIndices(x, y)
        local tile = level:getTile(column, row)

        if tile == nil then -- mouse over empty tile
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        else -- mouse over set tile
            love.mouse.setCursor(love.mouse.getSystemCursor("sizens"))
        end
    end
end

return LevelEditor