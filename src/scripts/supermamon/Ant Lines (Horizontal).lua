--[[ ******************************************************************
Ant Lines (Horizontal) v1.1
by @supermamon (github.com/supermamon/cylinder-scripts/)

Alternating Slide left/right transition.
Also works inside folders.
Compatible with iPad Landscape

v1.1 2014-02-16: Compatibility update for Cylinder v0.13.2.15
v1.0 2014-02-15: First Release
******************************************************************* ]]
local fade      = dofile("include/fade.lua")
local stayPut   = dofile("include/stayPut.lua")

-- MAIN --
return function(page, offset, screen_width, screen_height)

	-- track progress
	local percent = offset/page.width
	
	-- ** PAGE EFFECTS ** --
	stayPut(page,offset)
	fade(page,percent)

	-- ** ICON EFFECTS ** --
    local i = 0
	local direction = -1 
	local row = 0
	local lastX = page.width
	
    while true do
        i = i + 1
        local icon = page[i]
        if icon == nil then break end
		
		-- if this icon position is to the left of the last one
		if (lastX > icon.x) then row = row+1 end
		lastX = icon.x
		
		-- reverse the direction is row changes
		if (row % 2 == 0) then direction = 1 else direction = -1 end
		
		icon:translate(direction*offset, 0, 0)
    end	
	
end
