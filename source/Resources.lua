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
    return string.format("assets/animations/%s (%s).png", name, index)
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
Resources.animations.items[1] = LoadItemAnimation("assets/items/Yellow", 15)
Resources.animations.items[2] = LoadItemAnimation("assets/items/Blue", 25)
Resources.animations.items[3] = LoadItemAnimation("assets/items/Pink", 15)

-- Character Animations
Resources.animations.character = {}
Resources.animations.character["Idle"] = LoadCharacterAnimation("Idle", 15)
Resources.animations.character["Jump"] = LoadCharacterAnimation("Jump", 15)
Resources.animations.character["Walk"] = LoadCharacterAnimation("Walk", 15)
Resources.animations.character["Dead"] = LoadCharacterAnimation("Dead", 15)

-- Images
Resources.images = {}
Resources.images.snowflake = love.graphics.newImage("assets/snowflake.png")
Resources.images.background = love.graphics.newImage("assets/background.png")

-- Tile Maps
Resources.tileMap = newSpriteSheet(LoadTileImages("assets/tiles/"))

return Resources