--[[
- @supermamon | 13 Feb 2014

fade function
	view	: assign to page or icon
	percent	: percentage of transition
		
]]
return function (view, percent)
    if percent < 0 then percent = -percent end
    view.alpha = 1 - percent
end
