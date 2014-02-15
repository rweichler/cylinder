--[[
- @supermamon | 13 Feb 2014

Tornado v1.0

Merged the original Cube (Outside)and Spin
	
]]
local cube = dofile("rweichler/include/cube.lua")
local fade = dofile("supermamon/include/fade.lua")
local M_PI = 3.14159265

local function spin(view, percent)
    local angle = percent*M_PI*2

    local i = 0
    while true do
        i = i + 1
        local v = view[i]
        if v == nil then break end
        v:rotate(angle)
    end
end

return function(page, offset, width, height)
    local percent = offset/width
    spin(page, percent)
	cube(page, width, offset/width, false)
	fade(page,percent)
end
