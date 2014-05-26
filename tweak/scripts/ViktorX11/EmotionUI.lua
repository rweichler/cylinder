return function(page, offset, screen_width, screen_height)
	local percent = offset/page.width
	local radius = screen_width*2
	local yoffset = (radius^2 - offset^2)^0.5
	
	--page.alpha = 1 - math.abs(percent*1.5)
	page:rotate(percent*0.8, 0, 0, -1)	
	page:translate( -percent*200, 0, 0)
	page:translate(0, (radius-yoffset)*1.5, 0)
end
