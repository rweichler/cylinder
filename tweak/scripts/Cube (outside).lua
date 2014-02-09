local cube = include("include/cube.lua")

return function(page, offset, width, height)
    cube(page, offset/width, false)
end
