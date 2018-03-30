config = require("conf")

function GetIndexFromImage(images, image)
    for i = 1, #images do 
        if images[i] == image then
            return i 
        end
    end
    return 0
end

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
GridFile = "world.data"


function SaveGrid(images)
    assert(grid ~= nil, "No world to save")
    
    local file = io.open(GridFile, "w+")
    file:write(2, "\n")                            -- write version
    file:write(grid.rows, " ", grid.columns, "\n") -- write world size
    file:write(grid.position.x, "\n")              -- write scroll offset
    file:write(grid.position.y, "\n") 
    file:write(boolToNumber(config.ShowGrid), "\n")       -- write grid visibility  

    -- write tiles
    for tile, x, y in tiles(grid) do
        file:write(x, " ", y, " ", GetIndexFromImage(images, tile.image), "\n")
    end

    file:close()
    print("Saved world")
end

function LoadGrid(images)
    local file = io.open(GridFile, "r")
    
    if file == nil then
        print("No world exists to load")
        return false
    end
    
    local version = file:read("*number") -- read version 
    local rows = file:read("*number")    -- read and create world of appropriate size
    local columns = file:read("*number")
    local scrollOffset = {               -- read scroll offset
        x = file:read("*number"),
        y = file:read("*number")
    }

    config.ShowGrid = numberToBool(file:read("*number"))      -- read grid visbility

    if version == nil or 
       rows == nil or columns == nil or 
       scrollOffset.x == nil or scrollOffset.y == nil then
        return false
    end

    -- create new grid
    grid = createGrid(columns, rows)
    grid:scroll(scrollOffset.x, scrollOffset.y)

    -- read all saved tiles
    local tileCount = 0
    while true do
        local x = file:read("*number")
        if x == nil then
            break -- no (more) tiles to read
        end

        local y = file:read("*number")
        local imageIndex = file:read("*number")

        -- TODO: check if world is large enough for tile
        grid:addTile(x, y, images[imageIndex])
        tileCount = tileCount + 1
    end

    file:close()
    print(string.format("Restored %d tiles from %dx%d world", tileCount, rows, columns))
    return true
end