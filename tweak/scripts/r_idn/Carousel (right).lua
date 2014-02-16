local function swing(page, percent, height, width, offset)
    local i = 0
    while true do
        i = i + 1
        local icon = page[i]
        if icon == nil then break end

        icon:translate(percent*width, 0)
    end
    page:translate(0,0,percent*400)
end

local function fade(page,percent)
    page.alpha = 1 - math.abs(percent)
end

return function(page, offset, screen_width, screen_height)
    local percent = offset/page.width
    swing(page, percent, page.height, page.width)
    fade(page, percent)
end
