--[[
- @supermamon | 13 Feb 2014

FlipIcons (Horizontal) v1.0
		
]]
local fade = dofile("include/fade.lua")
local flipIcons = dofile("include/flipIcons.lua")
local stayPut = dofile("include/stayPut.lua")

return function(page, offset, screen_width, screen_height)
    local percent = offset/page.width
    flipIcons(page, percent, "h")
	fade(page,percent)
	stayPut(page, offset, page.width)
end
