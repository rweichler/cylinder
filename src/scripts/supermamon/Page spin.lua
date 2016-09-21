--[[ ******************************************************************
PageSpin v1.1
by @supermamon (github.com/supermamon/cylinder-scripts/)

Basically copied the Spin effect and applied it to the page. 
Nothing to brag about

v1.1 2014-02-16: Compatibility update for Cylinder v0.13.2.15
v1.0 2014-02-13: First release.
******************************************************************* ]]
local function pagespin(page, percent)
    local angle = percent*math.pi*2
    page:rotate(angle)
end

-- MAIN --
return function(page, offset, screen_width, screen_height)

	-- track progress
    local percent = offset/page.width

	-- ** PAGE EFFECTS ** --
    pagespin(page, percent)
	
	-- ** ICON EFFECTS ** --
end
