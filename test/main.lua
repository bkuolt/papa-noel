local Grid = {}

function createGrid(columns, rows)
    local grid = {
        columns = columns,
        rows = rows,
    }
    setmetatable(grid, {__index = Grid})

    -- create cells
    grid.tiles = {}
    for i = 0, rows do
        grid.tiles[i] = {}
        for j = 0, columns do
            grid.tiles[i][j] = { index = 0 }
        end
    end

    return grid
end

function Grid:getTileDimensions()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    return screenWidth / self.columns, screenHeight / self.rows
end

function Grid:getTile(x, y)
    -- TODO: handle scrolling
    local tileWidth, tileHeight = self:getTileDimensions()
    local row, column = math.floor(y / tileHeight), math.floor(x / tileWidth)
    return self.tiles[row][column]
end

function Grid:setTile(x, y, image)
    local tile = self:getTile(x, y)
    tile.image = image 
end

function Grid:draw()
    local tileWidth, tileHeight = self:getTileDimensions()
    for y = 0, self.columns do
        for x = 0, self.rows do
            local image = self.tiles[y][x].image
            if  image then
                local imageWidth, imageHeight = image:getData():getDimensions()
                love.graphics.draw(image, x * tileWidth, y * tileHeight, 0,
                                   tileWidth / imageWidth, tileHeight / imageHeight)
               -- love.graphics.rectangle("line", x * cellWidth, y * cellHeight, cellWidth, cellHeight)
            end
        end
    end
end

-- --------------------------------------------------------------

function loadTiles(path)
    assert(love.filesystem.isDirectory(path), "invalid path")
    
    -- ensure "/"
    if string.sub(path, -1) ~= "/" then
        path = path .. "/"
    end

    local images = {}
    
    -- load all images from the specified path 
    local files = love.filesystem.getDirectoryItems(path)
    for index, file in ipairs(files) do
        images[#images + 1] = love.graphics.newImage(path .. file)
    end

    print("Loaded " ..#images.. " tiles")
    return images
end

-- ..........................................................................

local images = loadTiles("Tiles/")
grid = createGrid(8, 8)

local currentImageIndex = 1 -- the currently seleted image



function love.wheelmoved(x, y)
    -- scroll current image
    local offset = 0
    if x > 0 then offset = 1 elseif x < 0 then offset = -1 end
    currentImageIndex = (currentImageIndex + offset) % #images

    -- update tile
    x, y = love.mouse.getPosition()
    grid:setTile(x, y, images[currentImageIndex])
end

function love.mousemoved(x, y, dx, dy, istouch)
    -- (1) get Index from current cell image
    -- (2) set current image ondex to it
    -- (3) update image
end

function love.mousepressed(x, y, button, istouch)
    grid:setTile(x, y, images[currentImageIndex])
end

-- ............................................................




function love.conf(t)
    t.window.vsync = false
    t.window.fullscreen = true
end


function love.draw()
    grid:draw()
end