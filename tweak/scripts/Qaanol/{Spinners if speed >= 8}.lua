local flick = dofile("include/flick.lua")
local speed = dofile("include/slideVelocity.lua")

return function(page, offset, screen_width, screen_height)
    if math.abs(speed(page, offset)) < 8 then
        flick(page, offset, 1, 1.25)
    else
        flick(page, offset, 3, 0.8)
    end
    
    page:translate(offset, 0, 0)
end