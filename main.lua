require "test/Animation"


local animation = LoadCoin(14, 10) -- LoadAnimation("test/animations/Idle (%u).png", 16, 15)

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
    animation:draw()
end
