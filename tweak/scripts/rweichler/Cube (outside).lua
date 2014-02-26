local cube = dofile("include/cube.lua")

return function (page, offset, screen_width, screen_height)
    local percent = math.abs(offset/page.width)

    cube(page, offset, false)

    page.alpha = 1 - math.pow(percent, 3)
end
