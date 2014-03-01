return function(page, offset, screen_width, screen_height)
    local percent = math.abs(offset/page.width)
    
    local numIcons = page.max_icons
    
    for i, icon in subviews(page) do
        local direction = -1
        local iconIndex = i-1
        if (offset < 0) then
            direction = 1
            iconIndex = numIcons-i
        end
        
        local curIconPercent = percent-((0.525/numIcons)*iconIndex)
        
        if (curIconPercent > 0) then
            dx = direction*math.pow(curIconPercent*3.5, 2)*page.width
            
            icon:translate(dx, 0, 0)
        end
    end
    
    page:translate(offset, 0, 0)
end