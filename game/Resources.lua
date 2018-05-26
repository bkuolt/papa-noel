Animation = require("Animation")

--[[
----------------------------------------------------
Resource Loading
----------------------------------------------------]]
local function LoadAnimation(name, fps, filenameFunction)
    local images = {}
    local index = 1

    while true do
        local filename = filenameFunction(name, index)
        if not love.filesystem.exists(filename) then
            break
        end
        images[index] = love.graphics.newImage(filename)
        index = index + 1
    end

    return Animation.LoadAnimation(images, fps)
end

local function LoadTileImages(path)
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

--[[
----------------------------------------------------
Helper
----------------------------------------------------]]
local function CreateItemFilename(path, index)
    local indexString
    if index < 10 then
         indexString = string.format("000%d", index)
    else indexString = string.format("00%d", index)
    end

    return string.format("%s/%s.png", path, indexString)
end

local function CreateAnimationFilename(name, index)
    return string.format("Art/animations/%s (%s).png", name, index)
end

local function LoadCharacterAnimation(name, fps)
    return LoadAnimation(name, fps, CreateAnimationFilename)
end

local function LoadItemAnimation(path, fps)
    return LoadAnimation(path, fps, CreateItemFilename)
end

--[[
----------------------------------------------------
Resources
----------------------------------------------------]]
local Resources  ={}

Resources.animations = {}

-- Items
Resources.animations.items = {}
Resources.animations.items[1] = LoadItemAnimation("Art/Crystals/Original/Yellow/gem2", 15)
Resources.animations.items[2] = LoadItemAnimation("Art/Crystals/Original/Blue/gem3", 25)
Resources.animations.items[3] = LoadItemAnimation("Art/Crystals/Original/Pink/gem1", 15)

-- Character Animations
Resources.animations.character = {}
Resources.animations.character["Idle"] = LoadCharacterAnimation("Idle", 15)
Resources.animations.character["Jump"] = LoadCharacterAnimation("Jump", 15)
Resources.animations.character["Walk"] = LoadCharacterAnimation("Walk", 15)

-- Images
Resources.images = {}
Resources.images.snowflake = love.graphics.newImage("Art/snowflake.png")
Resources.images.background = love.graphics.newImage("Art/background.png")

-- Tile Maps
Resources.tileMap = newSpriteSheet(LoadTileImages("Art/Tiles/"))

return Resources