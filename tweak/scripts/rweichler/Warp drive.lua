
return function(page, offset, screen_width, screen_height)
    local percent = offset/page.width

    page:translate(offset, 0, 0)
    page:scale(1 + percent)
    if percent < 0 then
        percent = percent/2
    end
    page.alpha = 1 - math.abs(percent)

end
