function SetColorKey(image, red, green, blue)
    local function filterFunction(x, y, r, g, b, a)
        if r == red and g == green and b == blue then
             return 0, 0, 0, 0
        else return r, g, b, a end
    end

    image:getData():mapPixel(filterFunction)
    image:refresh()
end