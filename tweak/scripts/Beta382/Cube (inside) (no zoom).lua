local cube = dofile("include/pageCube.lua")

return function(page, offset)
    cube(page, offset, true)
end