

return function(page, offset, screen_width, screen_height)

    page:translate(offset)

    local percent = offset/page.width

    if math.abs(percent) >= 0.5 then
        page.alpha = 0
    end

    local angle = math.pi
    if offset ~= 0 then
        angle = math.atan(PERSPECTIVE_DISTANCE/math.abs(offset))
    end

    page:rotate(angle*percent*2, 0, 1, 0)

end
