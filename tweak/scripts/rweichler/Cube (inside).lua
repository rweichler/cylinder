local cube = dofile("include/cube.lua")

return function(page, offset, screen_width, screen_height)
    cube(page, offset/page.width, true)
end
