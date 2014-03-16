--[[
    Double Door
    by gertab

    improved by rweichler

    An effect which makes your icons look like a double door opening.
    Requested by; reddit.com/u/JerryD2T
]]

return function(page, offset, screen_width, screen_height)

    page:translate(offset)

    local percent = math.abs(offset/page.width)
    for i, icon in subviews(page) do
        local m
        if icon.x + icon.width/2 > page.width/2 then
            m = 1
        else
            m = -1
        end
        icon:translate(m*2*percent*page.width/2)
    end

end
