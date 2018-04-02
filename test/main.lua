config = require("conf")
Grid = require("Grid")
require("SaveGame")

local currentImageIndex = 1         -- the currently seleted image
local currentCell = {x = 0, y = 0}
local images = {}

local function loadTiles(path)
    assert(love.filesystem.getInfo(path).type == "directory", "invalid path")
    
    -- ensure trailing '/'
    if string.sub(path, -1) ~= "/" then
        path = path .. "/"
    end

    -- load all images from the specified path 
    local files = love.filesystem.getDirectoryItems(path)
    for index, file in ipairs(files) do
        images[#images + 1] = love.graphics.newImage(path .. file)
    end

    print("Loaded " ..#images.. " tiles")
end

local function scrollCurrentImage(offset)
    currentImageIndex = (currentImageIndex + offset) % (1 + #images)
end

--[[
----------------------------------------------------
Mouse Callbacks
----------------------------------------------------]]
function love.mousemoved(x, y, dx, dy, istouch)
    currentCell.x, currentCell.y = grid:getTileIndices(x,y)

    if love.mouse.isDown(2) then -- left mouse button pressed and mouse moved
        love.mouse.setCursor(love.mouse.getSystemCursor("crosshair"))
        grid:scroll(dx, dy)
    else
        local tile = grid:getTile(x, y)
        if tile == nil or tile.image == nil then -- mouse over empty tile
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        else -- mouse over set tile
            love.mouse.setCursor(love.mouse.getSystemCursor("sizens"))
            currentImageIndex = GetIndexFromImage(images, tile.image)
        end
    end
end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then -- left click on tile
        local tile = grid:getTile(x, y)
        
        love.mouse.setCursor(love.mouse.getSystemCursor("sizens"))

        if tile ~= nil and tile.image ~= nil then
            scrollCurrentImage(1)
        end

        grid:setTile(x, y, images[currentImageIndex])
    elseif button == 2 then -- right click on set tile -> eras tile
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        grid:setTile(x, y, nil)
    end
end

function love.wheelmoved(x, y)
    scrollCurrentImage(y)

    -- update tile image
    local x, y = love.mouse.getPosition()
    grid:setTile(x, y, images[currentImageIndex])
end

--[[
----------------------------------------------------
Keyboard Callbacks
----------------------------------------------------]]
function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        SaveGrid(images)
        love.event.quit()       -- terminate
    elseif key == "space" then
        config.ShowGrid = not config.ShowGrid -- toggle grid visibility
    end
end

-- --------------------------------
local ParticleSystem = {}

function createParticleSystem(particleCount, image, particleSize)
    local particleSystem = {}
    setmetatable(particleSystem, {__index = ParticleSystem})

    particleSystem.image = image 
    particleSystem.particleSize = particleSize
    particleSystem.particles = {}
    
    for i = 1, particleCount do 
        particleSystem.particles[i] = particleSystem:createParticle()
    end

    particleSystem.initalized = true
    return particleSystem
end

function ParticleSystem:createParticle(existingParticle)
    local particle = existingParticle or {}
    
    particle.x = math.random(0, love.graphics.getWidth())

    if self.initalized then 
        particle.y = 0
    else
        particle.y = math.random(0, love.graphics.getHeight())
    end

    particle.gravity = math.random(100,300) -- TODO

    return particle
end

function ParticleSystem:update(delta)

    for _, particle in pairs(self.particles) do 
        particle.y = particle.y + particle.gravity * delta
        particle.x = particle.x + math.random(-20,20) * delta

        if particle.y >= love.graphics:getHeight() then
            self:createParticle(particle)
        end

    end
end

function ParticleSystem:draw()
    local scale = {
        x = self.particleSize / self.image:getWidth(),
        y = self.particleSize / self.image:getHeight()
    }

    love.graphics.setColor(255,255,255)
    for _, particle in pairs(self.particles) do 
        love.graphics.draw(self.image, particle.x, particle.y, 0, scale.x, scale.y)
    end

    -- TODO
end


--[[
----------------------------------------------------
Initialization
----------------------------------------------------]]
function love.load() 
    love.window.setTitle("Papa Noel Level Editor")
    love.graphics.setDefaultFilter("linear", "linear")

    loadTiles("Tiles/")

    if not LoadGrid(images) then 
         grid = createGrid(16, 8)
    end

    local backgroundImage = love.graphics.newImage("background.png")

    particleSystem = createParticleSystem(1000, love.graphics.newImage("a.png") ,16)

    grid:setBackground(backgroundImage)
end

function love.update(delta)
    local scrollOffset = { x = 0, y = 0 }

    if love.keyboard.isDown("left") then
        scrollOffset.x = config.ScrollSpeed * delta
    elseif love.keyboard.isDown("right") then
        scrollOffset.x = -config.ScrollSpeed * delta
    end
    if love.keyboard.isDown("up")then
        scrollOffset.y = config.ScrollSpeed * delta
    elseif love.keyboard.isDown("down") then
        scrollOffset.y = -config.ScrollSpeed * delta
    end

    -- TODO: update mouse cursor when moving
    grid:scroll(scrollOffset.x, scrollOffset.y)

    particleSystem:update(delta)
end


function love.draw()
    love.graphics.clear(32, 32, 32)
 
    grid:drawBackground()
    
    particleSystem:draw()
    
    grid:draw()

 
    local text = string.format("Tile %d/%d | %d FPS",currentCell.x, currentCell.y, love.timer.getFPS())
    love.graphics.print(text,0,0)
end