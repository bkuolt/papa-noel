local Grid = {}


function LoadAllTiles()
    local images = {}

    local files = love.filesystem.getDirectoryItems("Tiles")
    for index, file in ipairs(files) do
        images[#images + 1] = love.graphics.newImage("Tiles/" .. file)
    end
    print("Loaded " ..#images.. " tiles")
    return images
end
local images = LoadAllTiles()



function createGrid(columns, rows)
    local grid = {
        columns = columns,
        rows = rows,
    }
    setmetatable(grid, {__index = Grid})

    -- create cells
    grid.cells = {}
    for i = 0, rows do
        grid.cells[i] = {}
        for j = 0, columns do
            grid.cells[i][j] = { index = 0 }
        end
    end

    return grid
end

function Grid:getCellDimensions()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    return screenWidth / self.columns, screenHeight / self.rows
end

function Grid:getCell(x, y)
    local cellWidth, cellHeight = self:getCellDimensions()
    local row, column = math.floor(y / cellHeight), math.floor(x / cellWidth)
    return self.cells[row][column]
end

function Grid:draw()
    local cellWidth, cellHeight = self:getCellDimensions()
    for y = 0, self.columns do
        for x = 0, self.rows do
            local image = images[self.cells[y][x].index]
            if  image then
                local imageWidth, imageHeight = image:getData():getDimensions()
                love.graphics.draw(image, x * cellWidth, y * cellHeight, 0,
                                   cellWidth / imageWidth, cellHeight / imageHeight)
        
               -- love.graphics.rectangle("line", x * cellWidth, y * cellHeight, cellWidth, cellHeight)
            end
        end
    end
end


-- ..........................................................................

local i = 0

function love.onload()
    love.window.setFullscreen(true)
end


grid = createGrid(8, 8)



local image = love.graphics.newImage("tundraMid.png")


local currentImageIndex = 1
local currentCell 

local mousePosition = {}
local selectedCell


function updateImage(offset)
    if offset and currentCell ~= nil then
        if offset > 0 then currentCell.index = currentCell.index + 1 else currentCell.index = currentCell.index - 1 end
        currentCell.index = currentCell.index % #images
    end  
    currentImageIndex = currentCell.index
end



function updateMousePosition(x, y)
    mousePosition.x, mousePosition.y = x, y
    currentCell = grid:getCell(x, y)
end

function love.wheelmoved(x, y) 
    updateImage(x)
end

function love.mousemoved(x, y, dx, dy, istouch)
    updateMousePosition(x, y)
    updateImage(x)
end

function love.mousepressed(x, y, button, istouch)
    updateMousePosition(x, y)
    selectedCell = currentCell 
    updateImage()
end

-- ............................................................




function love.conf(t)
    t.window.vsync = false
    t.window.fullscreen = true
end


function love.draw()
    grid:draw()
end
