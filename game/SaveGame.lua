config = require("conf")
require("Item")
require("Animation")
require("Sprite")
require("Level")
require("Resources")

local function boolToNumber(value)
    if value == true then return 1 end
    return 0
end

local function numberToBool(number)
    if number > 0 then return true end
    return false
end

--[[
----------------------------------------------------
Saving and Restoring the world
----------------------------------------------------]]
local GridFile = "world.data"

function SaveGrid()
    assert(level.grid ~= nil, "No world to save")
    
    local file = io.open(GridFile, "w+")
    file:write(2, "\n")                                        -- write version
    file:write(level.grid.rows, " ", level.grid.columns, "\n") -- write world size
    file:write(level.grid.scrollOffset.x, "\n")                -- write scroll offset
    file:write(level.grid.scrollOffset.y, "\n") 
    file:write(boolToNumber(config.ShowGrid), "\n")            -- write grid visibility  

    -- write tiles
    for tile, x, y in level.grid.tiles:iterator() do
        local tileIndex = Resources.tileMap:getIndex(tile.sprite)
        file:write(x, " ", y, " ", tileIndex, "\n")
    end

    file:close()
    print("Saved world")
end



function LoadLevel()
    local file = io.open(GridFile, "r")
    assert(file, "no world exists to load");
    
    local version = file:read("*number") -- read version 
    local rows = file:read("*number")    -- read grid size
    local columns = file:read("*number")
    local scrollOffset = {               -- read scroll offset
        x = file:read("*number"),
        y = file:read("*number")
    }

    config.ShowGrid = numberToBool(file:read("*number"))  -- read grid visbility

    if version == nil or 
       rows == nil or columns == nil or 
       scrollOffset.x == nil or scrollOffset.y == nil then
        return false
    end

    -- create new grid
    level = createLevel(columns, rows)

    level.tileImages = tileImages
    level:setBackground(Resources.backgroundImage)

    -- read all saved tiles
    local tileCount = 0
    while true do
        -- read tile coordinates
        local x = file:read("*number")
        if x == nil then
            break
        end

        local y = file:read("*number")

        -- read tile index
        local imageIndex = file:read("*number")

        level:setTile(x, y, Resources.tileMap:getSprite(imageIndex))
        tileCount = tileCount + 1
    end

    level:scroll(scrollOffset.x, scrollOffset.y)

    file:close()

    -- Set items
    local items = {}
    items[1] = newItem(Resources.animations[1])
    items[2] = newItem(Resources.animations[2])
    items[3] = newItem(Resources.animations[4])
    

    level:setItem(-7,3, items[1])
    level:setItem(-6,3, items[1])
    level:setItem(-5,3, items[1])

    level:setItem(-2,2, items[2])
    level:setItem(-1,2, items[2])
    level:setItem( 0,2, items[2])

    level:setItem(2,3, items[3])
    level:setItem(3,3, items[3])
    level:setItem(4,3, items[3])

    level:setItem(-7,3, items[1])
    level:setItem(-6,3, items[1])
    level:setItem(-5,3, items[1])

    level:setItem(2,3, items[3])
    level:setItem(3,3, items[3])
    level:setItem(4,3, items[3])

    print(string.format("Restored %d tiles from %dx%d world", tileCount, rows, columns))
end