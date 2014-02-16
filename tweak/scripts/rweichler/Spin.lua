local function spin(view, percent)
    local angle = percent*math.pi*2

    local i = 0
    while true do
        i = i + 1
        local v = view[i]
        if v == nil then break end
        v:rotate(angle)
    end
end

return function(page, offset, screen_width, screen_height)
    local percent = offset/page.width
    spin(page, percent)
end
