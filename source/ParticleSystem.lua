--[[
----------------------------------------------------
ParticleSystem
----------------------------------------------------
]]
local ParticleSystem = {}

function createParticleSystem(particleCount, image, particleSize)
    local particleSystem = {
        image = image,
        particleSize = particleSize,
        particles = {},
        initalized = false
    }
    setmetatable(particleSystem, { __index = ParticleSystem })

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

    particle.gravity = math.random(100, 300)
    return particle
end

function ParticleSystem:update(delta)
    local screenHeight = love.graphics.getHeight()
    for _, particle in ipairs(self.particles) do
        particle.y = particle.y + particle.gravity * delta
        particle.x = particle.x + math.random(-50, 50) * delta

        if particle.y >= screenHeight then
            self:createParticle(particle)
        end
    end
end

function ParticleSystem:draw()
    if not self.image then
        return
    end

    local scale = {
        x = self.particleSize / self.image:getWidth(),
        y = self.particleSize / self.image:getHeight()
    }

    love.graphics.push("all")
        love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
        for _, particle in ipairs(self.particles) do
            love.graphics.draw(self.image, particle.x, particle.y, 0, scale.x, scale.y)
        end
    love.graphics.pop()
end

return ParticleSystem