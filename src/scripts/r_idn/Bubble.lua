local icon_random = dofile("../rweichler/include/icon_random.lua")

return function(page, offset, screen_width, screen_height)
    local magnitude = 0.4
    local percent = offset/page.width
    icon_random(page, offset/page.width, magnitude, function(icon, percent)
        icon:scale(1+math.abs(percent/2.5))
    end)
end
