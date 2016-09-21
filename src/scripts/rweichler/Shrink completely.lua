



return function(page, offset, screen_width, screen_height)

    local percent = math.abs(offset/page.width)*2
    if percent > 1 then percent = 1 end

    for i, icon in subviews(page) do
        icon:scale(1-percent)
    end


end
