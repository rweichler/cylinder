--[[
    Column's Spin (couldn't find a better name!!) v1.0
    by gertab
 
    An effect which makes your icons spin accarding to the columns numbers.
]]
local spin = dofile("include/spin.lua")
return function(page, offset, screen_width, screen_height)
    local percent = offset/page.width
    local num = 0
    local view = nil
    while true do
        num = num + 1
        view = page[num]
        if view == nil then break end
        -- numCopied holds the column no
        local numCopied = num%4
        if numCopied == 0 then numCopied = 4 end
        spin(view, percent, numCopied)
        view:translate(percent,0,0)
    end
end