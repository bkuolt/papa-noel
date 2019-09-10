local json = require("json");
local Animation = require("Animation")  -- TODO: rename
local love = require ("love");


local function loadJSON(filename)
    local file = assert(io.open(filename, "rb"), "could not load file");
    local string = file:read("*all")
    file:close()
    return json.decode(string);
end

function loadAnimation(filename)
    -- TODO: use asset directory as reference
    local jsonObject = assert(loadJSON(filename), "could not get JSON object");

    local images = {}
    for _, name in jsonObject.frames do
        table.insert(images, love.graphics.newImage(filename));
    end

    return Animation.LoadAnimation(images, jsonObject.fps)
end


local function loadTiles(path)
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
Resources
----------------------------------------------------]]
local resources  ={}

resources.animations = {}

-- Items
resources.animations.items = {
    loadAnimation("Crystals/Original/Yellow/gem2.json"),
    loadAnimation("Crystals/Original/Blue/gem3.json"),
    loadAnimation("Crystals/Original/Pink/gem1.json")
};

-- Character Animations
resources.animations.character = {
    Idle = loadAnimation("animations/idle.json"),
    Jump = loadAnimation("animations/jump.json"),
    Walk = loadAnimation("animations/walk.json"),
    Dead = loadAnimation("animations/dead.json")
};

-- Images
resources.images = {
    snowflake = love.graphics.newImage("Art/snowflake.png"),
    background = love.graphics.newImage("Art/background.png")
}
-- Tile Maps
resources.tileMap = newSpriteSheet(LoadTileImages("Art/Tiles/"))

return resources