--[[
- @supermamon | 13 Feb 2014

AlternateSpin v1.0

A modification of the built-in Spin effect.
This reverses the spin direction of every other icon

		
]]
local function spin(page, percent)
    local angle = percent*math.pi*2

    local i = 0
	local o = 0
    while true do
        i = i + 1
		o = i % 2
        local icon = page[i]
        if icon == nil then break end

		-- reverse the direction on every other icon
		if o ~= 0 then angle = -angle end
		
        icon:rotate(angle)
    end
end

return function(page, offset, screen_width, screen_height)
    local percent = offset/page.width
    spin(page, percent)
end
