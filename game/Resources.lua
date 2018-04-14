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

local function CreateAnimationFilename(index)
    return string.format("Art/animations/Idle (%s).png", index)
end

--[[
----------------------------------------------------
Resource Loading
----------------------------------------------------]]
local function LoadItemAnimation(path, fps)
    local images = {}
    for index = 1, 60 do
        images[index] = love.graphics.newImage(CreateItemFilename(path, index))
    end

    return LoadAnimation(images, fps)
end

local function LoadCharacterAnimation()
    local images = {}
    for i = 1, 16 do
        images[i] = love.graphics.newImage(CreateAnimationFilename(i))
    end

    local animation = LoadAnimation(images, 15)
    
    animation:play()
    return animation   
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

animations = {}
animations[1] = LoadItemAnimation("Art/Crystals/Original/Yellow/gem2", 15)
animations[2] = LoadItemAnimation("Art/Crystals/Original/Blue/gem3",25)
animations[4] = LoadItemAnimation("Art/Crystals/Original/Pink/gem1", 15)
animations[3] = LoadCharacterAnimation()

backgroundImage = love.graphics.newImage("Art/background.png")

tileMap = newSpriteSheet(LoadTileImages("Art/Tiles/"))