local cube = dofile("rweichler/include/cube.lua")

return function(page, offset, width, height)
    cube(page, width, offset/width, height)
end
