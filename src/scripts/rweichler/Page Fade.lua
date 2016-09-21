
return function(page, offset, screen_width, screen_height)

    local percent = math.abs(offset/page.layer.width)

    page.alpha = 1 - percent

    for i, icon in subviews(page) do
        icon.alpha = page.alpha
    end

end
