--[[
    Old Cards v1.0
    by gertab
 
    The page would proceed to the next page by the effect of old cards
]]
local spin = dofile("include/spin.lua")
return function(page, offset, screen_width, screen_height)
    local percent = offset/page.width
    page:translate(-offset, 0, 0)
    page:rotate(percent*math.pi)
end
