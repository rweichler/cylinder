--[[
- @supermamon | 13 Feb 2014

stayPut function
	view	: assign to page
	offset	: how far has the transition been
	width	: not used for now
		
]]
return function (view, offset, width)
    view:translate(offset, 0, 0)
end