



return function(page, offset, screen_width, screen_height)

    local percent = offset/page.width

    for i, icon in subviews(page) do
        icon:scale(1-math.abs(percent))
    end


end
