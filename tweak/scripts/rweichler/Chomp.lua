local function chomp(view, percent, height)
    local oldp = percent
    if percent < 0 then percent = -percent end

    local i = 0
    while true do
        i = i + 1
        local v = view[i]
        if v == nil then break end

        local mult = 1
        if v.y + v.height/2 < (height - v.height)/2 then mult = -1 end
        v:translate(0, mult*percent*height/2, 0)
    end
end

return function(page, offset, width, height)
    local percent = offset/width
    chomp(page, percent, height)
end
