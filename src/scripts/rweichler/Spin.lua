return function(page, offset, screen_width, screen_height)
    local percent = offset/page.width
    local angle = percent*math.pi*2

    for i, icon in subviews(page) do
        icon:rotate(angle)
    end
end
