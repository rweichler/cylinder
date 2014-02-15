--[[
- @supermamon | 13 Feb 2014

flipIcons function
	view	: assign to page
	percent	: percentage of transition
	direction: "h" for horizontal, "v" for vertical"
		
]]
return function (view, percent, direction)
	local M_PI = 3.14159265
    local angle = percent*M_PI
	local pitch = 0
	local yaw = 0
	
	if direction == "h" then
		yaw = 1
	elseif direction == "v" then
		pitch = 1
	end

    local i = 0
    while true do
        i = i + 1
        local v = view[i]
        if v == nil then break end
        v:rotate(angle, pitch, yaw)
    end
end