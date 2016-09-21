return function(page, offset, screen_width, screen_height)
	page:translate(offset, -(offset/page.width)*page.height, 0)
	page.alpha = 1 - math.abs(offset/page.width)
end