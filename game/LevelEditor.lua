function GetIndexFromImage(images, image)
    for i = 1, #images do 
        if images[i] == image then
            return i
        end
    end
    return 0
end

--[[
----------------------------------------------------
Level Editor
----------------------------------------------------]]
local currentImageIndex = 1         -- the currently seleted image

local function setCurrentImage(image)
    if image == nil then
        currentImageIndex = 1
        return
    end    
    currentImageIndex = GetIndexFromImage(level.tileImages, image)
end

local function getCurrentTileImage()
    return level.tileImages[currentImageIndex]
end

function scrollTileImage(tile, scrollOffset)
    setCurrentImage(tile.image)

    currentImageIndex = (currentImageIndex + scrollOffset) % #level.tileImages
    currentImageIndex = math.max(1, currentImageIndex)

    tile.image = level.tileImages[currentImageIndex]
end

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
             level:setTile(column, row, getCurrentTileImage())
        else scrollTileImage(tile, 1)
        end

        love.mouse.setCursor(love.mouse.getSystemCursor("sizens"))
    elseif button == 2 then  -- (right click) remove tile
        level:removeTile(column, row)
        setCurrentImage(nil)
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

    scrollTileImage(tile, scrollOffset)
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