--[[ ******************************************************************
PageSpin v1.2
by @supermamon (github.com/supermamon/cylinder-scripts/)

Basically copied the Spin effect and applied it to the page. 
Nothing to brag about

v1.3 2014-02-16: Compatibility update for Cylinder v0.13.2.15
v1.1 2014-02-15: Moved the icon spinning to a library
v1.0 2014-02-13: First release. Combo of the original Cube (Outside),
				Spin, Fade
******************************************************************* ]]
local cube = dofile("../rweichler/include/cube.lua")
local fade = dofile("include/fade.lua")
local iconSpin = dofile("include/iconSpin.lua")

-- MAIN --
return function(page, offset, screen_width, screen_height)

	-- track progress
    local percent = offset/page.width
	
	-- ** PAGE EFFECTS ** --
	cube(page, percent, false) -- cude(outside)
	fade(page,percent) 
	
	-- ** ICON EFFECTS ** --
	iconSpin(page, percent, 1)
end
