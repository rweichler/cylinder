--[[
- @supermamon | 13 Feb 2014

PageFlip effect v1.0
		
]]
local fade = dofile("include/fade.lua")
return function(page, offset, screen_width, screen_height)
	local percent = offset/page.width
    local angle = percent*math.pi
	local x = percent
    if percent < 0 then x = -x end

    page:translate(x, 0, 0)
    page:rotate(angle, 0, 1, 0)

	fade(page, percent)
end
