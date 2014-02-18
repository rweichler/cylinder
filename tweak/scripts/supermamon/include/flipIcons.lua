--[[
- @supermamon | 13 Feb 2014

flipIcons function
	page	: assign to page
	percent	: percentage of transition
	direction: "h" for horizontal, "v" for vertical"
		
]]
return function (page, percent, direction)
    local angle = percent*math.pi
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
        local icon = page[i]
        if icon == nil then break end
        icon:rotate(angle, pitch, yaw)
    end
end