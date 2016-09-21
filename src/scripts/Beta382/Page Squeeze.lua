return function(page, offset, screen_width, screen_height)
    page:translate(0, 0, -math.abs(offset/2))
end