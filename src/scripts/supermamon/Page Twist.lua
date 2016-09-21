--[[ ******************************************************************
Page Twist v1.1
by @supermamon (github.com/supermamon/cylinder-scripts/)

Twisting effect between the current and next page

v1.1 2014-02-16: Compatibility update for Cylinder v0.13.2.15
v1.0 2014-02-15: First release.
******************************************************************* ]]

local fade = dofile("include/fade.lua")

return function(page, offset, screen_width, screen_height)
		
	-- track progress
	local percent = offset/page.width 
	
	-- rotations
	local tumbles = 0.5					
    local angle = percent*math.pi*2*tumbles	
	
	-- ** PAGE EFFECTS ** --
	fade(page,percent)
	
	--local x = math.abs(percent)
    --page:translate(x, 0, 0)
    page:rotate(-2/3*angle, 1, 0, 0)
    --page:translate(-x, 0, 0)	
	
	
		
end
