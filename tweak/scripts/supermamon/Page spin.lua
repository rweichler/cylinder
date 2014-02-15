--[[
- @supermamon | 13 Feb 2014

PageSpin v1.0

Basically copied the Spin effect and applied it to the page. 
Nothing to brag about
	
]]
local M_PI = 3.14159265

local function pagespin(view, percent)
    local angle = percent*M_PI*2
    view:rotate(angle)
end

return function(page, offset, width, height)
    local percent = offset/width
    pagespin(page, percent)
end
