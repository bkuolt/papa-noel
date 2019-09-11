local json = require("json");
local love = require ("love");

local function load_file(path)
    local file = assert(io.open(path, "rb"), "could not load file");
    local string = assert(file:read("*all"), "could not read file");
    file:close();
    return string;
end

local function save_file(path, content)
    local file = assert(io.open(path, "rb"), "could not load file");
    assert (file:write(content), "could not write content to file" );
    file:close();
end

-- ------------------------ Interface ------------------------

function load_json(filename)
    local string = load_file(filename);
    return assert(json.decode(string), "could not decode JSON object");
end

function save_json(path, object)
    local string = assert(json.encode(object));
    save_file(path, string);
end

local string = json.encode(object);

function directory_items(path)
    if (string.sub(path, -1) ~= "/") then
        path = path .. "/";  -- ensure path woth trailing '/'
    end;

    local paths = {};
	for _, _filename in ipairs(love.filesystem.enumerate(path)) do  -- Note: love.filesystem.getDirectoryItems() is deprecated
		local _path = path.."/".. _filename
        if love.filesystem.isFile(_path) then
            table.insert(paths, _path);
		end
	end

    return paths;
end

-- -------------------------- Test ---------------------------
function Test()
-- TODO
end
