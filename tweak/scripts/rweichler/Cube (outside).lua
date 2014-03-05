local cube = dofile("include/cube.lua")

return function (page, offset, screen_width, screen_height)
    local percent = math.abs(offset/page.width)

    local x, z, angle = cube(page, offset, false)

    local threshold = math.abs(math.atan((PERSPECTIVE_DISTANCE - z)/x))
    angle = math.abs(angle)

    if angle > threshold then
        page.alpha = 1 - (angle - threshold)/(math.pi/2 - threshold)
    else
        page.alpha = 1
    end
end
