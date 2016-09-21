local M_PI = 3.14159265

local function animateur(view, width, percent, is_inside)
    local angle = percent*M_PI
    local m = is_inside and 1/3 or -2/3
    local x = width/2
    if percent < 0 then x = -x end
    local i = 0
    while true do
        i = i + 1
        local v = view[i]
        if v == nil then break end
        view[i]:translate(3.5*x, 0, 0)
        view[i]:rotate(m*angle, 0, 1, 0)
        view[i]:translate(-x*3.5, 0, 0)
    end
end

return function(page, offset, width, height)
    animateur(page, width, offset/width, false)

    local percent = offset/width
    if percent < 0 then percent = -percent end

    page.alpha = 1 - percent^2
end
