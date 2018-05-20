require("GameObject")

local Character = {}
setmetatable(Character, {__index = GameObject})

function newCharacter(x, y, width, height, animation)
    local character = newGameObject(x, y, width, height, animation)
    setmetatable(character, {__index = Character})
    return character
end