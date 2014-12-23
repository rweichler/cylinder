local flick = dofile("include/flick.lua")

return function(page, offset, screen_width, screen_height)
    flick(page, offset, 1, 1.2)
    page:translate(offset, 0, 0)
end