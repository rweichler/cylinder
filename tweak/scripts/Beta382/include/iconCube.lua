return function (page, iconNum, percent, isHorizontal, isForwards)
    if not page[iconNum] then return end
    
    local icon = page[iconNum]
    
    local angle = percent * (math.pi/2)

    local R = page.width/2
    
    if (not isHorizontal) then R = page.height/2 end
    
    local xOffset = page.width/2 - icon.x - icon.width/2
    local yOffset = page.height/2 - icon.y - icon.height/2
    
    icon.layer.x = icon.layer.x + xOffset
    icon.layer.y = icon.layer.y + yOffset
    
    local ddirectional = -math.sin(angle)*R
    local dz = -(1-math.cos(angle))*R
    
    if (not isForwards) then
        ddirectional = -ddirectional
        angle = -angle
    end
    
    if (isHorizontal) then
        icon:translate(ddirectional, 0, dz)
        icon:rotate(-angle, 0, 1, 0)
    else
        icon:translate(0, ddirectional, dz)
        icon:rotate(angle, 1, 0, 0)
    end
    
    icon:translate(-xOffset, -yOffset, 0)
    
    local threshold = math.abs(math.atan((PERSPECTIVE_DISTANCE - dz)/ddirectional))
    
    if (math.abs(angle) > threshold) then
        icon.alpha = 1 - (math.abs(angle)-threshold)/(math.pi/2 - threshold)
    else
        icon.alpha = 1
    end
end
