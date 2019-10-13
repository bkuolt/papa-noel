-- Copyright 2019 Bastian Kuolt

local function loadAnimations()
    print("loaded animations");
    -- TODO
end

local function loadFonts()
    print("loaded fonts");
    -- TODO
end

local function loadTiles()
    print("loaded tiles");
    -- TODO
end

local function loadSounds()
    print("loaded sounds");
    -- TODO
end

local function loadBackgrounds()
    print("loaded backgrounds");
    -- TODO
end

function loadAssets()
    local startTime = love.timer.getTime();

    loadAnimations()
    loadFonts()
    loadTiles()
    loadBackgrounds()
    loadSounds()

    local duration = love.timer.getTime() - startTime
    print("loading took %ss", duration)
end