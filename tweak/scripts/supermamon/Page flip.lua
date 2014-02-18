--[[ ******************************************************************
Page Flip v1.1
by @supermamon (github.com/supermamon/cylinder-scripts/)

v1.1 2014-02-16: Compatibility update for Cylinder v0.13.2.15
v1.0 2014-02-13: First release.
******************************************************************* ]]
local fade = dofile("include/fade.lua")
return function(page, offset, screen_width, screen_height)

	-- track progress
	local percent = offset/page.width
	
    local angle = percent*math.pi
	--local x = math.abs(percent)

	-- ** PAGE EFFECTS ** --
    fade(page,percent)
	page:rotate(angle, 0, 1, 0)
    	
	-- ** ICON EFFECTS ** --
end
