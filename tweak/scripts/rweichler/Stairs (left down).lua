local stairs = dofile("include/stairs.lua")

return function(page, offset, screen_width, screen_height)
    return stairs(page, offset/page.width, true)
end
