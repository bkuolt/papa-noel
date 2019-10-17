-- Copyright 2019 Bastian Kuolt
require("config")
require("savegame")
require("graphics")
require("input")
require("font")

local level = {}

local state = {
    mode = ""
}

local font = newFont("assets/font/SF Atarian System Bold Italic.ttf", 100)
local loadingTime = 0;

local function showLoadingScreen()
    loadingTime = loadingTime + love.timer.getDelta();

    local num = math.ceil(loadingTime % 3)
    local text = "Loading "
    for i = 1, num do text = text .. "." end

    love.graphics.clear(0,0,1)
    font:print(text)
end

--[[ -------------------------------------------------------------- --]]

function love.load()
    state.mode = "loading"

    -- love.window.minimize();
    love.window.setTitle("Papa Noel [Work in Progress]")
    loadConfig()
    -- love.window.restore();

    showLoadingScreen()
    -- TODO: loadAssets()
    -- TODO: level = loadGame()
    -- TODO: Start playing level
end

function love.quit()
    saveGame(level)
    print("terminating Papa Noel")
end

--[[ -------------------------------------------------------------- --]]

function love.draw()
    if state.mode == "loading" then
        showLoadingScreen()
    end
    -- TODO
end



local function onPause()
    -- TODO: Ignore when loading screen is active
    -- TODO: If game is paused
        -- TODO: resume the level (and all it's components)
        -- TODO: hide pause menu
    -- TODO: If the game not pause
        -- TODO: pause the level (and all it's components)
        -- TODO: pause pause menu
end

function love.keypressed(key, scancode, isrepeat)
    if key == "ESC" then
        love.event.quit()
    elseif key == "P" then
        onPause()
    else
        notifyKeyPress(key)
    end
end

function love.keyreleased(key, scancode, isrepeat)
    notifyKeyRelease(key)
end