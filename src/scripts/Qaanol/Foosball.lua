local flick = dofile("include/flick.lua")
local speed = dofile("include/slideVelocity.lua")

return function(page, offset, screen_width, screen_height)
    local s = speed(page, offset)
    
    if s > 0 then
        flick(page, offset, 1, 1.2, 3, 1, true, false)
    elseif s < 0 then
        flick(page, offset, 1, 1.2, 3, 1, false, false)
    end
    page:translate(offset, 0, 0)
end