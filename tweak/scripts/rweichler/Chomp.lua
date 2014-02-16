return function(page, offset, screen_width, screen_height)
    local percent = offset/page.width


    if percent < 0 then percent = -percent end

    local i = 0
    while true do
        i = i + 1
        local icon = page[i]
        if icon == nil then break end

        local mult = 1
        if icon.y + icon.height/2 < page.height/2 then mult = -1 end
        icon:translate(0, mult*percent*screen_height/2, 0)
    end

end
