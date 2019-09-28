local love = require ("love");
require("io_util");
local Animation = require("Animation")  -- TODO: rename


local function get_path(filename) 
    return "../asset/" .. filename;
end

local function loadAnimation(filename)
    local json_object = load_json(get_path(filename));
    assert(json_object.fps and json_object.frames, "invalid JSON format");

    local frames = {}  -- of type love.graphics.Image
    for _, _frame in ipairs(json_object.frames) do
        local image = love.graphics.newImage(get_path(_frame));
        table.insert(frames, image);
    end

    return Animation.LoadAnimation(frames, json_object.fps)
end

local function loadImages(filename)
    local json_object = load_json(get_path(filename));

    for _name, _filename in ipairs(json_object) do
        local image = love.graphics.newImage(get_path(_filename));
        json_object[_name] = image;  -- get the filename and load a love.graphics.Image from its path
    end

    return json_object;
end

--[[
----------------------------------------------------------------------
Load all images in a directory and returns them as a sprite sheet.
----------------------------------------------------------------------]]
local function loadSpriteSheet(path)
    local directory_items = directory_items(get_path(path));

    local images = {}
    for _, filename in ipairs(directory_items) do
        local image = love.graphics.newImage(get_path(filename));
        table.insert(images, image);
    end

    local message = string.format("Loaded %i images to a spritesheet", #images);
    print(message);

    return newSpriteSheet(images);
end

function loadConfig(path)
    local json = load_json(path);
    return {  -- converts to a Papa Noel compatible configuration table
        mode = json.mode,
        ShowGrid = json.showGrid,
        ScrollSpeed = json.scrollSpeed,
        ShowBoundingBoxes = json.showBoundingBoxes
    }
end

function saveConfig(path, config)
    local object = { -- converts from a Papa Noel config to a JSON file
        mode = config.mode,
        showGrid = cofig.ShowGrid,
        showBoundingBoxes = config.ShowBoundingBoxes,
        scrollSpeed = config.ScrollSpeed,
    }

    return io_utils.save_json(path, object);
end

--[[
----------------------------------------------------
Globally accesible graphics resources
----------------------------------------------------]]
local function loadResources()
    local start_time = love.timer.getTime();

    local resources = {
        animations = {
            items = {
                loadAnimation("Crystals/Original/Yellow/gem2.json"),
                loadAnimation("Crystals/Original/Blue/gem3.json"),
                loadAnimation("Crystals/Original/Pink/gem1.json")
            },
            character = {
                Idle = loadAnimation("animations/idle.json"),
                Jump = loadAnimation("animations/jump.json"),
                Walk = loadAnimation("animations/walk.json"),
                Dead = loadAnimation("animations/dead.json")
            }
        },

        images = loadImages("images.json"),
        tileMap = loadSpriteSheet("tiles");
    };

    local duration = love.timer.getTime() - start_time;
    local message = string.format("Loaded game resources (%fs)", duration);
    print(message);

    return resources;
end

return loadResources();

