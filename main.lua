
--------------------------------------------
-- Particle
--------------------------------------------
local function createParticle()
    return {
        x = 0, y = 0,
        size = 0,
        lifetime = 0
    }
end

local function createRange(min_x, max_x, min_y, max_y)
    return {
        min = {x = min_x, y = min_y},
        max = {x = max_x, y = max_y}
    }
end

--------------------------------------------
-- ParticleSystem
--------------------------------------------
local ParticleSystem = {}

local function newParticleSystem(image, count)
    local particleSystem = {}
    setmetatable(particleSystem, {__index = ParticleSystem})

    particleSystem.particleVelocity = {x = 0, y = 0}
    particleSystem.particleLifetime = 0

    -- create sprite batch
    particleSystem.spriteBatch = love.graphics.newSpriteBatch(image, count)
    
    -- create particles
    particleSystem.particles = {}
    for i = 1, count do
        particleSystem.particles[i] = createParticle()
    end

    particleSystem.dirty = true
    return particleSystem
end

function ParticleSystem:getRandomPosition()
    return { x = math.random(self.positionRange.min.x, self.positionRange.max.x),
             y = math.random(self.positionRange.min.x, self.positionRange.max.y) }
end

function ParticleSystem:getRandomSize()
    return self.particleSize + math.random(-self.particleSizeVariance, self.particleSizeVariance)
end

function ParticleSystem:setPosition(min_x, max_x, min_y, max_y)
    self.positionRange = {
        min = {x = min_x, y = min_y},
        max = {x = max_x, y = max_y}
    }
    self.dirty = true
end

function ParticleSystem:setSize(size, variance)
    self.particleSize = size
    self.particleSizeVariance = variance
    self.dirty = true
end

function ParticleSystem:setVelocity(x, y)
    -- TODO
    self.dirty = true
end

function ParticleSystem:respawParticle(particle)
    particle.lifetime = 0
    particle.size = self:getRandomSize()
    particle.position = self:getRandomPosition()
end

function ParticleSystem:respaw()
    for _, particle in ipairs(self.particles) do
        self:respawParticle(particle)
    end
    self.dirty = false
end

function ParticleSystem:updateParticle(particle, delta)
    -- update position
    particle.x = particle.x + (self.velocity.x  * delta)
    particle.y = particle.x + (self.velocity.y  * delta)

    -- update and check if lifespan is exceeded
    particle.lifetime = particle.lifetime + delta
    if particle.lifetime >= self.particleLifetime then
        self:respawParticle(particle)
    end
end

function ParticleSystem:update(delta)
    if delta == 0 then
        return -- avoid unecessary calculations
    end

    if self.dirty then 
        self:respaw()
    end

    self.spriteBatch:clear()

    for _, particle in ipairs(self.particles) do
        self:updateParticle(particle, delta)
        self.spriteBatch:add(particle.x, particle.y)
    end
end

function ParticleSystem:draw()
    love.graphics.draw(self.spriteBatch)
end

--------------------------------------------
-- Love2D Callbacks
--------------------------------------------
function LoadImage(filename, red, green, blue)
    local image = love.graphics.newImage(filename)
    
    -- apply colorkey
    if red and green and blue then
        local imageData = image:getData()
        imageData:mapPixel(
            function (x, y, r, g, b, a)
                a = not (red == r and blue == b and green == g)
                return r, g, b, a
            end
        )        
        imageData:refresh()
    end
    
    return image
end


function love.load()
    -- creates a particle system with 1000 particles
    local image = love.graphics.newImage("snowflake.png")
    particleSystem = newParticleSystem(image, 1000)

    local width, height = love.graphics.getDimensions()

    particleSystem:setPosition(0, width, 0, 0) -- x = [0, width], y = 0
    particleSystem:setSize(32, 10)             -- 32 pixels 
    particleSystem:setVelocity(0, 10)         -- -10 pixels per second
end

function love.update(delta)
    particleSystem:update(delta)
end

function love.draw()
    love.graphics.clear()
    particleSystem:draw()
end
