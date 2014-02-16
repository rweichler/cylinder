--[[
- @supermamon | 13 Feb 2014

fade function
	view	: assign to page or icon
	percent	: percentage of transition
		
]]
return function (view, percent)
    view.alpha = 1 - math.abs(percent)
end
