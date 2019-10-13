-- Copyright 2019 Bastian Kuolt
local json_lua = require("json_lua/json")

local json = {}

function json.parse(path)
    local file = assert(io.open(path, "rb"), "could not load " .. path);
    local string = assert(file:read("*all"), "could not read " .. path);
    file:close();
    return assert(json_lua.decode(string), "could not decode " .. path .. " to a JSON object");
end

return json;