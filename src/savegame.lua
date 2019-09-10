local json = require "json"
local config = require("conf")  -- the global Papa Noel configuration
require("Resources")

function loadLevel(filename)
    local file = assert(io.open(filename, "rb"), "could not load file");
    local content = file:read("*all")
    file:close()
    return json.decode(content)
end

local function decodeJSONToLevel(onject)
--[[
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
--]]
end

-- ---------------------------------------------------------

local function encodeToJSON(level)
    assert(config, "make sure you required the conf.lua file")

    local object = {}
    object.version = "4";
    object.grid = { x = level.grid.rows, y = level.grid.columns };
    object.scrollOffset = { x = level.grid.scrollOffset.x, y = level.grid.scrollOffset.y };
    object.isGridVisible = config.ShowGrid;

    object.tiles = {}
    for tile, x, y in level.tiles:iterator() do
        object.tiles[#object.tiles + 1] = {
            position = { x = x, y = y },
            sprite = Resources.tileMap:getIndex(tile.animation);
        };
    end

    return object;
end

--[[
    @brief Saves the current Papa Noel to a savegmae file (JSON).
    @filenmae Path for the savegame.
    @level Papa Noel Level to save.
--]]
function saveLevel(filename, level)
    assert(filename ~= nil, "there is no path to save to");
    assert(level ~= nil, "there is no level to save");
    -- TODO: assert more properties

    local file = assert(io.open(filename, "wb+"), "could not write file");
    local object = encodeToJSON(level);
    local string = json.encode(object);
    file:write(string);
    file:close();
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