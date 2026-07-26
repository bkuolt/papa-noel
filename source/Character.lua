require("GameObject")

--[[
----------------------------------------------------
Character
----------------------------------------------------
]]
local Character = {}
setmetatable(Character, { __index = GameObject })

function newCharacter(x, y, width, height, animation)
    local character = newGameObject(x, y, width, height, animation)
    setmetatable(character, { __index = Character })
    return character
end

function Character:startWalking()
    self.setAnimation("Walk")
    -- TODO: Implement movement
end

function Character:stopWalking()
    self.setAnimation("Idle")
    -- TODO: Stop movement
end

-- Support multiple animations per game object
-- Add walking