--[[
- @supermamon | 13 Feb 2014

PageFlip effect v1.0
		
]]
local fade = dofile("include/fade.lua")
return function(page, offset, width, height)
	local M_PI = 3.14159265
	local percent = offset/width
    local angle = percent*M_PI
	local x = percent
    if percent < 0 then x = -x end

    page:translate(x, 0, 0)
    page:rotate(angle, 0, 1, 0)

	fade(page,percent)
end
