--[[
- @supermamon | 13 Feb 2014

AlternateSpin v1.0

A modification of the built-in Spin effect.
This reverses the spin direction of every other icon

		
]]
local M_PI = 3.14159265

local function spin(view, percent)
    local angle = percent*M_PI*2

    local i = 0
	local o = 0
    while true do
        i = i + 1
		o = i % 2
        local v = view[i]
        if v == nil then break end

		-- reverse the direction on every other icon
		if o ~= 0 then angle = -angle end
		
        v:rotate(angle)
    end
end

return function(page, offset, width, height)
    local percent = offset/width
    spin(page, percent)
end
