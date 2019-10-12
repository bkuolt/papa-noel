require("config")
require("Item")
require("Animation")
require("Sprite")
require("Level")
local Resources = require("resources")
require("Character")
local resources = require("resources")

-- -------------------- JSON Integration --------------------
require("io_util");

local function decodeLevel(path)
    return loadJSON(path)
    -- TODO: Adjust the image paths
end

local function getPath(imageOrAnimation)
    -- TODO
end

local function encodeLevel(level)
    local json = {}
    json.version = "4";
    json.grid = { x = level.grid.rows, y = level.grid.columns };

    json.tiles = {}
    for tile, x, y in level.tiles:iterator() do
        json.tiles[#json.tiles + 1] = {
            position = { x = x, y = y },
            sprite = getPath(tile.animation);
        };
    end
    -- TODO: set "background.png");
    json.background = getPath(level.background);
    json.scrollOffset = { x = level.grid.scrollOffset.x, y = level.grid.scrollOffset.y };

    json.items = {}
    for _, item in level.getItems() do
        json.items[#json.items + 1] = {
            position = { x = item.x, y = item.y },
            sprite = getPath(item.animation);
        };
    end

    json.save = function (path) saveJSON(json, path) end;
    return json;
end

--[[
----------------------------------------------------
Game State Saving and Restoring
----------------------------------------------------]]
local Filename = love.filesystem.getSourceBaseDirectory() .. "/savegame.json"

function SaveGame(path)
    -- TODO
end

function LoadGame(path)
    local json = loadJSON(path)
    level = loadLevel(json.level)
    level.character.x = json.characterx;
    level.character.y = json.characterx.y;

    json.items = {}
    for _, item in level.getItems() do
        json.items[#json.items + 1] = {
            position = { x = item.x, y = item.y },
            sprite = getPath(item.animation);
        };
    end 
end

--[[
----------------------------------------------------
Level Loading
----------------------------------------------------]]

--[[
    @brief Saves the current Papa Noel to 'savegame.json'.
    @level Papa Noel level to save to hard disk.
--]]
function SaveLevel(level)
    assert(not level ~= nil, "there is no level to save");
    local json = encodeLevel(level)
    json.save(Filename)
    print("saved game")
end

--[[
  @brief Saves the current level state to 'savegame.json'.
  @level Papa Noel level to save to hard disk.
]]
function LoadLevel(level)
    level = decodeLevel(Filename);

    -- Manually set items until animated items can be load from a JSON file
    level:setItsm(-7,3, Resources.animations.items[1])
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

    level:setCharacter(-12,4) -- manually replace character

    print("loaded game")
    return true  -- TODO: rather assert than handle with boolean success values
end

--[[
---------------------------------------------------------
Main
---------------------------------------------------------
if #arg ~= 2 then
    print("usage: lua savegame.lua <file>");
    --os.exit(-1);
end

local filename = arg[2] -- "level.json"


-- local level = loadLevel(filename);
-- local message = string.format("tiles: %i", #level.tiles);
-- print(message)
 --]]
