-- Copyright 2019 Bastian Kuolt
local json = require("jsons")

--[[
    The global game assets
]]
local assets = {}

local function loadAnimations(animations)
    print("loaded animations");
    -- TODO
end

local function loadFonts(fonts)
    print("loaded fonts");
    -- TODO
end

local function loadTiles(tiles)
    print("loaded tiles");
    -- TODO
end

local function loadSounds(sounds)
    print("loaded sounds");
    -- TODO
end

local function loadBackgrounds(backgrounds)
    print("loaded backgrounds");
    -- TODO
end

function loadAssets()
    local startTime = love.timer.getTime();

    local assets = json.parse("assets.json")
    loadAnimations(assets.animations)
    loadFonts(assets.fonts)
    loadTiles(assets.tiles)
    loadBackgrounds(assets.backgrounds)
    loadSounds(assets.sounds)

    local duration = love.timer.getTime() - startTime
    print("loading took %ss", duration)
end