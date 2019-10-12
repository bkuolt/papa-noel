local json = require("json");
local love = require ("love");

-- ------------------------ Interface ------------------------

function loadJSON(path)
    local file = assert(io.open(path, "rb"), "could not load " .. path);
    local string = assert(file:read("*all"), "could not read " .. path);
    file:close();
    return assert(json.decode(string), "could not decode " .. path .. " to a JSON object");
end

function saveJSON(json, path)
    local string = assert(json.encode(json));
    local file = assert(io.open(path, "rb"), "could not open " .. path);
    assert(file:write(json), "could not write to " .. path);
    file:close();
end

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
