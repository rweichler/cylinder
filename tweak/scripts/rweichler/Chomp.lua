return function(page, offset, screen_width, screen_height)
    local percent = offset/page.width

    if percent < 0 then percent = -percent end

    for i, icon in subviews(page) do
        local mult = 1
        if icon.y + icon.height/2 < page.height/2 then mult = -1 end
        icon:translate(0, mult*percent*screen_height/2, 0)
    end

end
