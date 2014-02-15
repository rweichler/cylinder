local fade = dofile("include/fade.lua")

local M_PI = 3.14159265

return function(page, offset, width, height)

	local percent = offset/width
    local angle = percent*M_PI
	local x = percent
    if percent < 0 then x = -x end
	

    page:translate(offset, 0, -offset)
    --page:rotate(angle, 0, 1, 0)
    --page:translate(-x, 0, 0)	
	fade(page, percent)
	
end
