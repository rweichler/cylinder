

return function(page, offset, screen_width, screen_height)

    page:translate(offset)

    local percent = offset/page.width

    offset = math.abs(offset)

    if math.abs(percent) >= 0.5 then
        page.alpha = 0
    end

    local angle = offset == 0 and math.pi or math.atan(PERSPECTIVE_DISTANCE/offset)

    page:rotate(angle*percent*2, 0, 1, 0)

end
