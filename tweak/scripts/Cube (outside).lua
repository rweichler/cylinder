local cube = dofile("include/cube.lua")

return function(page, offset, width, height)
    cube(page, width, offset/width, false)

    local percent = offset/width
    if percent < 0 then percent = -percent end

    page.alpha = 1 - percent*percent*percent
end
