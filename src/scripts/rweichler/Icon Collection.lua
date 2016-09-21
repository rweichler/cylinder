--CRAAAZY trig stuff!!!

local function distance(x1, y1, x2, y2)
    return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2))
end

return function(page, offset, screen_width, screen_height)
    local percent = math.abs(offset/page.width)

    local center_x = page.width/2
    local center_y = page.height/2

    for i, icon in subviews(page) do
        local x = icon.x + icon.width/2
        local y = icon.y + icon.height/2

        local hypotenuse = percent*distance(x, y, center_x, center_y)
        local angle = math.atan((center_x - x)/(center_y - y))
        if y > center_y then hypotenuse = -hypotenuse end

        local dx = hypotenuse*math.sin(angle)
        local dy = hypotenuse*math.cos(angle)

        icon:translate(dx, dy, 0)
    end
end
