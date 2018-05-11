local Character = {}

function newCharacter()
    local character = {}
    setmetatable(character, {__index = Character})

    return character
end

function Character:setPosition(x, y)
    self.position.x = x
    self.position.y = y
end

function Character:draw() -- TODO: refactor function
    love.graphics.push("all")
        love.graphics.translate(self.grid.scrollOffset.x , self.grid.scrollOffset.y )
        animations[3]:draw(-1500, 315, 450, 400)
    love.graphics.pop()
end