require "test/Animation"


function getFilename(index)
        local indexString
        if index < 10 then
            indexString = string.format("000%d", index)
        else
            indexString = string.format("00%d", index)
        end

        return string.format("test/Art/Crystals/Original/Blue/gem3/%s.png", indexString)
end

local animation = LoadAnimation(getFilename, 58, 15)

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

function love.draw()
    animation:draw(0,0, 100,100)
end
