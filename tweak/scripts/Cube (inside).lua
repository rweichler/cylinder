local cube = include("include/cube.lua")

return function(page, width, offset)
    cube(page, offset/width, true)
end
