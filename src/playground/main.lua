-- Copyright 2019 Bastian Kuolt
require("config")
require("savegame")
require("graphics")

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
end

local function onPause()
    -- TODO: handle pause events
end

function love.keypressed(key, scancode, isrepeat)
    if key == "ESC" then
        love.event.quit()
    else if key == "P" then
        onPause()
    end
end