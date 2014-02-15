--[[
- @supermamon | 13 Feb 2014

FlipIcons (Vertical) v1.0
		
]]
local fade = dofile("include/fade.lua")
local flipIcons = dofile("include/flipIcons.lua")
local stayPut = dofile("include/stayPut.lua")

return function(page, offset, width, height)
    local percent = offset/width
    flipIcons(page, percent, "v")
	fade(page,percent)
	stayPut(page,offset, width)
end
