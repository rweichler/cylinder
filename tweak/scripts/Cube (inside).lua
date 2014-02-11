local cube = dofile("include/cube.lua")

return function(page, offset, width, height)
    cube(page, width, offset/width, true)
end
