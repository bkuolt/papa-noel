--[[
----------------------------------------------------
HashMap2D
----------------------------------------------------]]
local HashMap2D = {}

function newHashMap2D()
    local hashMap = { values = {}, size = 0 }
    setmetatable(hashMap, { __index = HashMap2D })
    return hashMap
end

function HashMap2D:add(x, y, value)
    assert(x and y, "invalid hash map keys")
    
    if value == nil then 
        return
    end

    self.values[y] = self.values[y] or {}
    self.values[y][x] = value
    self.size = self.size + 1
end

function HashMap2D:remove(x, y)
    if self:get(x,y) == nil then
        return
    end

    self.values[y][x] = nil
    if next(self.values[y], nil) == nil then
        self.values[y] = nil
    end
    self.size = self.size - 1
end

function HashMap2D:size()
    return self.size
end

function HashMap2D:get(x, y)
    assert(x and y, "invalid hash map keys")
    if self.values[y] == nil then
        return nil
    end
    return self.values[y][x]
end

--[[
----------------------------------------------------
HashMap2D Iterator
----------------------------------------------------]]
local function nextValue(table, x, y)
    if y == nil then
        y = next(table, nil)
        if y == nil then
            return
        end
    end

    x = next(table[y], x)
    if x == nil then
        y = next(table, y)
        if y ~= nil then
            x = next(table[y], nil)
        end
    end

    return x, y
end

function HashMap2D:iterator()
    if self.values == nil then 
        return function() return end
    end

    local current = {}
    current.x, current.y = nextValue(self.values, nil, nil)

    return function()
        if current.x == nil and current.y == nil then 
            return
        end

        local tmp = { x = current.x, y = current.y }
        current.x, current.y = nextValue(self.values, current.x, current.y)

        return self.values[tmp.y][tmp.x], tmp.x, tmp.y
    end
end