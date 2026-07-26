--[[
----------------------------------------------------
TileSelector
----------------------------------------------------
]]
local TileSelector = {
    currentSpriteIndex = 1
}

function TileSelector.setCurrentTile(sprite)
    assert(sprite, "Invalid sprite object")
    local index = Resources.tileMap:getIndex(sprite)
    if index then
        TileSelector.currentSpriteIndex = index
    end
end

function TileSelector.getCurrentTile()
    return Resources.tileMap:getSprite(TileSelector.currentSpriteIndex)
end

function TileSelector.scroll(tile, scrollOffset)
    assert(tile, "Invalid tile object")
    assert(scrollOffset, "Invalid scroll offset")

    local spriteCount = Resources.tileMap:getSpriteCount()
    if spriteCount > 0 then
        TileSelector.currentSpriteIndex = (TileSelector.currentSpriteIndex - 1 + scrollOffset) % spriteCount + 1
        tile.animation = TileSelector.getCurrentTile()
    end
end

--[[
----------------------------------------------------
Level Editor
----------------------------------------------------
]]
local LevelEditor = {}

--[[
@brief Creates a new tile on the clicked cell in the grid or scrolls the current tile image
@param x,y Mouse coordinates in pixels
@param button Currently pressed mouse button (Love2D values)
]]
function LevelEditor.onClick(x, y, button)
    local column, row = level.grid:getTileIndices(x, y)

    if button == 1 then -- (Left click) Set or scroll tile image
        local tile = level:getTile(column, row)
        if tile == nil then
            level:setTile(column, row, TileSelector.getCurrentTile())
        else
            TileSelector.setCurrentTile(tile.animation)
            TileSelector.scroll(tile, 1)
        end

        love.mouse.setCursor(love.mouse.getSystemCursor("sizens"))
    elseif button == 2 then -- (Right click) Remove tile
        level:removeTile(column, row)
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
    end
end

--[[
@brief Scrolls the image, if existent, of the current grid cell
@param x,y Mouse coordinates in pixels
@param scrollOffset Mouse wheel scroll units
]]
function LevelEditor.onMouseWheelMoved(x, y, scrollOffset)
    local column, row = level.grid:getTileIndices(x, y)

    local tile = level:getTile(column, row)
    if tile == nil then
        return -- No tile to scroll image for
    end

    TileSelector.setCurrentTile(tile.animation)
    TileSelector.scroll(tile, scrollOffset)
end

function LevelEditor.onMouseMove(x, y, dx, dy)
    if love.mouse.isDown(2) then -- Right mouse button pressed and mouse moved
        level:scroll(dx, dy)
        love.mouse.setCursor(love.mouse.getSystemCursor("crosshair"))
    else
        local column, row = level.grid:getTileIndices(x, y)
        local tile = level:getTile(column, row)

        if tile == nil then -- Mouse over empty tile
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        else -- Mouse over set tile
            love.mouse.setCursor(love.mouse.getSystemCursor("sizens"))
        end
    end
end

return LevelEditor