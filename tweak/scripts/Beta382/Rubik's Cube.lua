local function cubeRow(page, row, percent, offset)
    if (offset > 0) then
        if (percent > 1) then percent = 1
        elseif (percent < 0) then percent = 0 end
    elseif (offset < 0) then
        if (percent < -1) then percent = -1
        elseif (percent > 0) then percent = 0 end
    end
    
    for i, icon in subviews(page) do
        
        if (math.floor((i-1)/page.max_columns)+1) == row then
            local angle1 = percent * (math.pi/2)

            local Rx = page.width/2
            local Ry = page.height/2
            local xOffset = Rx - icon.x - icon.width/2
            local yOffset = Ry - icon.y - icon.height/2
            
            icon.layer.x = icon.layer.x + xOffset
            icon.layer.y = icon.layer.y + yOffset
            
            icon:translate(-math.sin(angle1)*Rx, 0, -(1-math.cos(angle1))*Rx)
            icon:rotate(-angle1, 0, 1, 0)
            icon:translate(-xOffset, -yOffset, 0)
            
            icon.alpha = 1 - math.pow(math.abs(percent), 3)
        end
    end
end

return function(page, offset, screen_width, screen_height)
    percentPerRow = 1/page.max_rows
    
    for i=1, page.max_rows do
        local percent = offset/page.width
        if (offset > 0) then percent = (percent-(i-1)*percentPerRow)/percentPerRow
        elseif (offset < 0) then percent = (percent+percentPerRow*(page.max_rows-i))/percentPerRow end
        
        cubeRow(page, i, percent, offset)
    end
    
    page.layer.x = page.layer.x + offset
end









