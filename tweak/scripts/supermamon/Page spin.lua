--[[
- @supermamon | 13 Feb 2014

PageSpin v1.0

Basically copied the Spin effect and applied it to the page. 
Nothing to brag about
	
]]
local function pagespin(view, percent)
    local angle = percent*math.pi*2
    view:rotate(angle)
end

return function(page, offset, screen_width, screen_height)
    local percent = offset/page.width
    pagespin(page, percent)
end
