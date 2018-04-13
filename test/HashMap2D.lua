local HashMap2D = {}

function HashMap2D.create()
    local hashMap = { values = {} }
    setmetatable(hashMap, { __index = HashMap2D })
    return hashMap
end

function HashMap2D:add(x, y, value)
    assert(x and y, "invalid hash map keys")
    self.values[y] = self.values[y] or {}
    self.values[y][x] = value
end

function HashMap2D:remove(x, y)
    assert(x and y, "invalid hash map keys")
    self.values[y][x] = nil
    if next(self.values[y], nil) == nil then
        self.values[y] = nil
    end
end

function HashMap2D:get(x, y)
    assert(x and y, "invalid hash map keys")
    if self.values[y] == nil then
        return nil
    end
    return self.values[y][x]
end

function HashMap2D:iterator()
    -- TODO
end

return HashMap2D