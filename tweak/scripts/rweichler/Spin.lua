local function spin(view, percent)
    local angle = percent*math.pi*2

    for i, icon in subviews(page) do
        v:rotate(angle)
    end
end

return function(page, offset, screen_width, screen_height)
    local percent = offset/page.width
    spin(page, percent)
end
