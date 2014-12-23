local flick = dofile("include/flick.lua")
local speed = dofile("include/slideVelocity.lua")

return function(page, offset, screen_width, screen_height)
    local s = speed(page, offset)
    
    if s > 0 then
        flick(page, offset, 3, 2)
    elseif s < 0 then
        flick(page, offset, 1, 1.25)
    end
    
    page:translate(offset, 0, 0)
end