
local function add(a, b)
    return { x = a.x + b.x, 
             y = a.y + b.y };
end

local function sub(a, b)
    return { x = a.x - b.x,
             y = a.y - b.y };
end

local function eq(a, b)
    return a.x == b.x and a.y == b.y;
end

function vec2(_x, _y)
    -- return {x = x, y = y }

    local vector = {
        x = _x or 0, y = _y or 0
    }
    local mt = {
        __add = add,
        __sub = sub,
        __eq = eq
    }
    setmetatable(vector, mt);
    return vector
end

function Color(r, g, b, a)
    return {r = 0, g = 0, b = b, a = a }
end 

 Colors = {
    black = Color(0, 0, 0, 255),
    white = Color(255, 255, 255, 255)
}

