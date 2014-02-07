local M_PI = 3.14159265

local function spin(view, percent)
    local angle = percent*M_PI*2

    local i = 0
    while true do
        i = i + 1
        local v = view[i]
        if v == nil then break end
        v:rotate(BASE, angle, 0, 0, 1)
    end
end

return function (view, percent, is_inside)
    local angle = percent*M_PI/2
    if not is_inside then angle = -angle end
    view:rotate(BASE, angle, 0, 1, 0)

    if percent < 0 then percent = -percent end
    view.alpha = 1 - percent
end
