config = require("conf")
require("Item")
require("Animation")
require("Sprite")
require("Level")
local Resources = require("resources")
require("Character")
require("savegame")

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
local GridFile = love.filesystem.getSourceBaseDirectory() .. "/world.data"

function SaveLevel(level)
    saveLevel("savegame.json", level);
    print("Saved savegame to savegame.json");
end

function LoadLevel()
    print(GridFile)
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

    level:setBackground(Resources.images.background)

    -- read all saved tiles
    local tileCount = 0
    for line in file:lines() do -- file:read("*l") und string.gmatch
        print(line)
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
    -- TODO: Also save items
    --print( string.match("Item 5 5", "Item %d %d"))

    -- Set items
    level:setItem(-7,3, Resources.animations.items[1])
    level:setItem(-6,3, Resources.animations.items[1])
    level:setItem(-5,3, Resources.animations.items[1])

    level:setItem(-2,2, Resources.animations.items[2])
    level:setItem(-1,2, Resources.animations.items[2])
    level:setItem( 0,2, Resources.animations.items[2])

    level:setItem(2,3, Resources.animations.items[3])
    level:setItem(3,3, Resources.animations.items[3])
    level:setItem(4,3, Resources.animations.items[3])

    level:setItem(-7,3, Resources.animations.items[1])
    level:setItem(-6,3, Resources.animations.items[1])
    level:setItem(-5,3, Resources.animations.items[1])

    level:setItem(2,3, Resources.animations.items[3])
    level:setItem(3,3, Resources.animations.items[3])
    level:setItem(4,3, Resources.animations.items[3])
    -- HOW TO HARCODE

    print(string.format("Restored %d tiles from %dx%d world", tileCount, rows, columns))

    -- Set character
    level:setCharacter(-12,4)

    return true
end