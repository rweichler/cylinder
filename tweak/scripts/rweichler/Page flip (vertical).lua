

return function(page, offset, screen_width, screen_height)

    page:translate(offset)

    local percent = offset/page.width

    if math.abs(percent) >= 0.5 then
        page.alpha = 0
    end

    page:rotate(math.atan(-offset/PERSPECTIVE_DISTANCE), 0, 1, 0)
    page:rotate(math.pi*percent, 1, 0, 0)


end
