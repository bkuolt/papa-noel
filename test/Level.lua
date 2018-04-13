require("ParticleSystem")
require("Grid")
require("Animation")



--[[
----------------------------------------------------
 Level
----------------------------------------------------]]
local Level = {}

function createLevel(rows, columns)
    local level = {
        backgroundScroll = { x = 0, y = 0 },
        background = nil,
        grid = createGrid(rows, columns),
        particleSystem = createParticleSystem(2000, love.graphics.newImage("a.png") ,10)
    }
    setmetatable(level, {__index = Level})

    -- --------------------------------
    level.items = {}
    -- --------------------------------

    return level
end


-- --------------------------------
-- --------------------------------
local function LoadItemAnimation(filename, fps)
    local getFilename = function (index)
            local indexString
            if index < 10 then
                indexString = string.format("000%d", index)
            else
                indexString = string.format("00%d", index)
            end

            return string.format("%s/%s.png", filename, indexString)
        end

    return LoadAnimation(getFilename, 60, fps)
end

local function LoadCharacterAnimation()
    local getFilename = function (index)
            return string.format("animations/Idle (%s).png", index)
        end

    local anim = LoadAnimation(getFilename, 16, 12)
    anim:play()
    return anim   
end



local animations = {}
animations[1] = LoadItemAnimation("Art/Crystals/Original/Yellow/gem2", 15)
animations[2] = LoadItemAnimation("Art/Crystals/Original/Blue/gem3",25)
animations[3] = LoadCharacterAnimation()


function Level:setItem(x, y,animation)
    local item = {}
    item.animation = animation
    item.animation:play()
    item.x = x
    item.y = y

    self.items[#self.items + 1] = item
end


function Level:drawItems()

    local tileWidth, tileHeight = self.grid:getTileDimensions()

    love.graphics.push("all")
         love.graphics.translate(self.grid.scrollOffset.x , self.grid.scrollOffset.y )

        

        for _, item in ipairs(self.items) do 

            item.animation:draw(item.x * tileWidth, item.y * tileHeight, tileWidth, tileHeight)
        end
    love.graphics.pop()
end


function Level:drawCharacter()
    
    love.graphics.push("all")
        love.graphics.translate(self.grid.scrollOffset.x , self.grid.scrollOffset.y )

    local tileWidth, tileHeight = self.grid:getTileDimensions()

        animations[3]:draw(-1500,315, 450, 400)

    love.graphics.pop()
end
-- --------------------------------
-- --------------------------------





local set = false

function Level:setTile(column, row, tile)
    self.grid:setTile(column, row, tile)
    
    if set == false then
        self:setItem(-2,2, animations[2])
        self:setItem(-1,2, animations[2])
        self:setItem( 0,2, animations[2])
        
        self:setItem(-7,3, animations[1])
        self:setItem(-6,3, animations[1])
        self:setItem(-5,3, animations[1])
        

        set = true
    end
end

function Level:getTile(column, row)
    return self.grid:getTile(column, row)
end

function Level:removeTile(column, row)
    return self.grid:removeTile(column, row)
end

function Level:setBackground(image)
    self.background = image
end

function Level:scroll(x, y)
    if self.grid:scroll(x, y) then 
        self:scrollBackground(x / 2)
    end
end

function Level:scrollBackground(x)
    self.backgroundScroll.x = self.backgroundScroll.x + x
end

function Level:update(delta)
    self.particleSystem:update(delta)
end

function Level:drawBackground()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local imageWidth, imageHeight = self.background:getDimensions()
    
    love.graphics.push()
        local translation = self.backgroundScroll.x % screenWidth

        love.graphics.draw(self.background,  translation, 0, 0,  screenWidth / imageWidth, screenHeight / imageHeight)
        love.graphics.draw(self.background,  translation + screenWidth, 0, 0, screenWidth / imageWidth, screenHeight / imageHeight)
        love.graphics.draw(self.background,  translation - screenWidth, 0, 0, screenWidth / imageWidth, screenHeight / imageHeight)
    love.graphics.pop()
end

function Level:drawSnow()
    self.particleSystem:draw()
end

function Level:drawTiles()
    self.grid:draw()
end

function Level:draw()
    self:drawBackground()
    self:drawSnow()
    self:drawTiles()
    self:drawItems()
    self:drawCharacter()
end
