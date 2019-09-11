local json = require("json");
local Animation = require("Animation")  -- TODO: rename
local love = require ("love");

local path_asset = "../asset/";

-- ------------------------------------------------

local function loadJSON(filename)
    local file = assert(io.open(filename, "rb"), "could not load file");
    local string = file:read("*all")
    file:close()
    return json.decode(string);
end

-- ------------------------------------------------

local function loadAnimation(filename)
    local jsonObject = loadJSON(path_asset .. filename);
    assert(jsonObject, "could not get JSON object");

    local images = {}
    for _, frame in jsonObject.frames do
        table.insert(images, love.graphics.newImage(path_asset .. frame));
    end

    return Animation.LoadAnimation(images, jsonObject.fps)
end

local function loadTiles(path)
    path = path_asset .. path;

    -- load all images from the specified path
    assert(love.filesystem.getInfo(path).type == "directory", "path must point to a directory")
    if (string.sub(path, -1) ~= "/") then path = path .. "/";  -- ensure path woth trailing '/'
    local fileList = love.filesystem.getDirectoryItems(path)

    local images = {}
    for index, file in ipairs(fileList) do
        table.insert(images, love.graphics.newImage(path .. file));
    end

    print("Loaded " .. #images .. " tiles")
    return images
end

local function loadImages(filename)
    local path = path_asset .. filename;
    local jsonObject = assert(loadJSON(path), "could not get JSON object");

    for name, filename in ipairs(jsonObject) do
        local path = path_asset .. filename;
        jsonObject[name] = love.graphics.newImage(path);
    end
    return jsonObject;
end

--[[
----------------------------------------------------
Resources
----------------------------------------------------]]
local function loadResources()
    local resources  = {}

    resources.animations = {}  -- TODO: check out whey this member is needed

    print("Loading level items...");
    resources.animations.items = {
        loadAnimation("Crystals/Original/Yellow/gem2.json"),
        loadAnimation("Crystals/Original/Blue/gem3.json"),
        loadAnimation("Crystals/Original/Pink/gem1.json")
    };

    printf("Loading character animations...");
    resources.animations.character = {
        Idle = loadAnimation("animations/idle.json"),
        Jump = loadAnimation("animations/jump.json"),
        Walk = loadAnimation("animations/walk.json"),
        Dead = loadAnimation("animations/dead.json")
    };

    print("Loading images...");
    resources.images = loadImages("images.json");
    
    print("Creating sprite sheet...")
    resources.tileMap = newSpriteSheet(loadTiles("tiles"));
end

return loadResources();  -- returns a table containing all the resources needed by Papa Noel