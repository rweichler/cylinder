local cube = dofile("include/cube.lua")

return function (page, offset, screen_width, screen_height)
    local percent = offset/page.width
    cube(page, percent, false)

    if percent < 0 then percent = -percent end

    page.alpha = 1 - math.pow(percent, 3)
end
