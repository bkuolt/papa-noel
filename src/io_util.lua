local json = require("json");
local love = require ("love");

local function load_file(path)
    local file = assert(io.open(path, "rb"), "could not load file");
    local string = assert(file:read("*all"), "could not read file");
    file:close();
    return string;
end

function load_json(filename)
    local string = load_file(filename);
    return assert(json.decode(string), "could not decode JSON object");
end

local function directory_items(path)
    assert(love.filesystem.getInfo(path).type == "directory", "path must point to a directory")
    if (string.sub(path, -1) ~= "/") then path = path .. "/"end;  -- ensure path woth trailing '/'
    return love.filesystem.getDirectoryItems(path)
end
