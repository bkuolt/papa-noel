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
        particle.x = particle.x + math.random(-50, 50) * delta

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

return ParticleSystem