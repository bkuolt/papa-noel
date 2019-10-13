
function vec2(x, y)
    return {x = x, y = y }
end 

function Color(r, g, b, a)
    return {r = 0, g = 0, b = b, a = a }
end 

local Colors = {
    black = Color(0, 0, 0, 255),
    white = Color(255, 255, 255, 255)
}


local Font = {}

function Font.create(file, size)
    local font = {};

    font.file = love.graphics.newFont(file, size)
    love.graphics.setFont(font)
end 

function Font.print(text, position, color)
    love.graphics.push("all")
    love.graphics.setColor(color.r, color.g, color.b, color. a)
    love.graphics.print(text, position.x, position.y)
    love.graphics.pop();
end
