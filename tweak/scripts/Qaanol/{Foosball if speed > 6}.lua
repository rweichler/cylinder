local flick = dofile("include/flick.lua")
local speed = dofile("include/slideVelocity.lua")

return function(page, offset, screen_width, screen_height)
    local threshold = 6
    local s = speed(page, offset)
    
    if s > threshold then
        flick(page, offset, 1, 1.25, 3, 1, true, false)
    elseif s < -threshold then
        flick(page, offset, 1, 1.25, 3, 1, false, false)
    elseif s ~= 0 then
        flick(page, offset, 1, 1.25)
    end
    
    if s ~= 0 then
        page:translate(offset, 0, 0)
    end
end