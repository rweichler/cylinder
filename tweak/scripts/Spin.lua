local M_PI = 3.14159265

local function spin(view, percent)
    local angle = percent*M_PI*2

    local i = 0
    while true do
        i = i + 1
        local v = view[i]
        if v == nil then break end
        v:rotate(angle)
    end
end

return function(page, width, offset)
    local percent = offset/width
    spin(page, percent)
end
