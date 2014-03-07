local iconCube = dofile("include/iconCube.lua")

return function(page, offset, screen_width, screen_height)
    -- A value from 0 to 1 that specifies how long each row should take to complete animating
    -- Change this and only this, hackers
    local animationDuration = 1/page.max_rows
    
    local percent = offset/page.width
    
    for i, icon in subviews(page) do
        local iconRow = math.floor((i-1)/page.max_columns)
        
        local curRowStartP = (1-animationDuration)*(iconRow/(page.max_rows-1))
        
        if (offset < 0) then
            curRowStartP = curRowStartP-1+animationDuration
        end
        
        local iconCurPercent = (percent-curRowStartP)*(1/animationDuration)
        
        if (offset >= 0) then
            if (iconCurPercent > 1) then iconCurPercent = 1
            elseif (iconCurPercent < 0) then iconCurPercent = 0 end
        elseif (offset < 0) then
            if (iconCurPercent < -1) then iconCurPercent = -1
            elseif (iconCurPercent > 0) then iconCurPercent = 0 end
        end
        
        iconCube(page, i, iconCurPercent, true, true)
    end
    
    page:translate(offset, 0, 0)
end
