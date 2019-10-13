-- Copyright 2019 Bastian Kuolt
require("config")
require("savegame")
require("graphics")
require("input")

local level = {}

local function showLoadingScreen()
    local font = gfx.Font.create("assets/font/SF Atarian System Bold.ttf", 100)
    love.graphics.clear(Colors.black);
    font.print("Loading...", white, vec2(0, 0));
end

function love.onLoad()
    loadConfig()
    showLoadingScreen()
    loadAssets()
    level = loadGame()
    -- TODO: Start playing level
end

function love.quit()
    saveGame(level)
    print("terminating Papa Noel")
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
    else if key == "P" then
        onPause()
    else
        notifyKeyPress(key)
    end
end

function love.keyreleased(key, scancode, isrepeat)
    notifyKeyRelease(key)
end