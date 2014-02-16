
return function(page, offset, screen_width, screen_height)

    local percent = math.abs(offset/page.width)

    page:translate(offset, 0, 0)

    page.alpha = 1 - percent

end
