
Font = {}

function newFont(path, size)
    local font = {}
    setmetatable(font, {__index = Font })

    font.handle = love.graphics.newFont(path, size)
    return font;
end

function Font:print(text)
    love.graphics.push("all")
    love.graphics.setFont(self.handle)
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.print(text)
    love.graphics.pop();
end
