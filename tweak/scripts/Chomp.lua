local cube = include("include/cube.lua")

local M_PI = 3.14159265

local function chomp(view, percent, width)
    local oldp = percent
    if percent < 0 then percent = -percent end

    local i = 0
    while true do
        i = i + 1
        local v = view[i]
        if v == nil then break end

        local mult = 1
        if i <= 8 then mult = -1 end
        v:translate(BASE, 0, mult*percent*width/2, -percent*50)
    end
end

return function(page, width, offset)
    local percent = offset/width
    chomp(page, percent, width)
    cube(page, percent, true)
end
