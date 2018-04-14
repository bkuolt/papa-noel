local HashMap2D = {}

function HashMap2D.create()
    local hashMap = { values = {}, size = 0 }
    setmetatable(hashMap, { __index = HashMap2D })
    return hashMap
end

function HashMap2D:add(x, y, value)
    assert(x and y, "invalid hash map keys")
    self.values[y] = self.values[y] or {}
    self.values[y][x] = value
    self.size = self.size + 1
end

function HashMap2D:remove(x, y)
    assert(x and y, "invalid hash map keys")
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

function HashMap2D:iterator()
    -- TODO
end

return HashMap2D