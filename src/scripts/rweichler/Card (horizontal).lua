

return function(page, offset, screen_width, screen_height)

    page.layer.x = page.layer.x + offset

    local percent = offset/page.width

    if math.abs(percent) >= 0.5 then
        page.alpha = 0
    end

    page:rotate(-math.pi*percent, 0, 1, 0)

end
