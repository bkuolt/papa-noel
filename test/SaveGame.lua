config = require("conf")
require("Animation")


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
    assert(level.grid ~= nil, "No world to save")
    
    local file = io.open(GridFile, "w+")
    file:write(2, "\n")                            -- write version
    file:write(level.grid.rows, " ", level.grid.columns, "\n") -- write world size
    file:write(level.grid.scrollOffset.x, "\n")              -- write scroll offset
    file:write(level.grid.scrollOffset.y, "\n") 
    file:write(boolToNumber(config.ShowGrid), "\n")       -- write grid visibility  

    -- write tiles
    for tile, x, y in tiles(level.grid) do
        file:write(x, " ", y, " ", GetIndexFromImage(level.tileImages, tile.image), "\n")
    end

    file:close()
    print("Saved world")
end

local function loadTileImages(path)
    assert(love.filesystem.getInfo(path).type == "directory", "invalid path")
    
    -- ensure trailing '/'
    if string.sub(path, -1) ~= "/" then
        path = path .. "/"
    end

    -- load all images from the specified path 
    local files = love.filesystem.getDirectoryItems(path)

    local images = {}
    for index, file in ipairs(files) do
        images[#images + 1] = love.graphics.newImage(path .. file)
    end

    print("Loaded " ..#images.. " tiles")
    return images
end



-- --------------------------------
local function LoadItemAnimation(filename, fps)
    local getFilename = function (index)
            local indexString
            if index < 10 then
                indexString = string.format("000%d", index)
            else
                indexString = string.format("00%d", index)
            end

            return string.format("%s/%s.png", filename, indexString)
        end

    return LoadAnimation(getFilename, 60, fps)
end

local function LoadCharacterAnimation()
    local getFilename = function (index)
            return string.format("animations/Idle (%s).png", index)
        end

    local anim = LoadAnimation(getFilename, 16, 12)
    anim:play()
    return anim   
end


animations = {}
animations[1] = LoadItemAnimation("Art/Crystals/Original/Yellow/gem2", 15)
animations[2] = LoadItemAnimation("Art/Crystals/Original/Blue/gem3",25)
animations[4] = LoadItemAnimation("Art/Crystals/Original/Pink/gem1", 15)
animations[3] = LoadCharacterAnimation()
-- --------------------------------


function LoadLevel()
    -- if not LoadLevel(images) then 
    --     level = createLevel(16, 8)
    -- end

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
    level = createLevel(columns, rows)

    level.tileImages = loadTileImages("Tiles/")
    local backgroundImage = love.graphics.newImage("background.png")
    level:setBackground(backgroundImage)


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
        level:setTile(x, y, level.tileImages[imageIndex])
        tileCount = tileCount + 1
    end

    level:scroll(scrollOffset.x, scrollOffset.y)

    file:close()
    print(string.format("Restored %d tiles from %dx%d world", tileCount, rows, columns))

    -- -----------------------------------------
    level:setItem(-2,2, animations[2])
    level:setItem(-1,2, animations[2])
    level:setItem( 0,2, animations[2])
    
    level:setItem(-7,3, animations[1])
    level:setItem(-6,3, animations[1])
    level:setItem(-5,3, animations[1])

    level:setItem(2,3, animations[4])
    level:setItem(3,3, animations[4])
    level:setItem(4,3, animations[4])
     
    -- ----------------------------------------- 

    return true
end