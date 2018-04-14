--require "test/Animation"
--require "test/Sprite"

--*********************

--******************
local map = HashMap2D.create()

map:add(0, 0, "A")
map:add(1, 0, "B")
map:add(2, 0, "C")

map:add(0, 2, "D")

for value, x, y in map:iterator() do
    print(y, x, value)
end




local function getFilename(index)
        local indexString
        if index < 10 then
            indexString = string.format("000%d", index)
        else
            indexString = string.format("00%d", index)
        end

        return string.format("test/Art/Crystals/Original/Blue/gem3/%s.png", indexString)
end

----------------------------------------------------------- TODO
function LoadSpriteSheet()
    local images = {}
    for i = 1, 58 do 
        images[#images + 1] = love.graphics.newImage(getFilename(i))
    end

    return newSpriteSheet(images)
end

local spriteSheet = LoadSpriteSheet()
local animation = LoadAnimation(spriteSheet, 15)

function love.keypressed(key, scancode, isrepeat)
    if key == "p" then 
        if animation:isPaused() then
            animation:unpause()
        else 
            animation:pause()
        end
    end
end

function love.load()
    animation:play()
end


  
--print(sprite.quad.x, sprite.quad.y)
--print(sprite.quad.width, sprite.quad.height)


function love.draw()
    --local sprite = spriteSheet:getSprite(1)
    --sprite:draw(0,0, 144,144)

   -- love.graphics.draw(spriteSheet.canvas, 0,0)

    animation:draw(0,0, 100,100)
end
