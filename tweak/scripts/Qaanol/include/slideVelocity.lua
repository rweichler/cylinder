local previous = 0    -- Most recent value of page offset
local velocity = 0    -- Starting velocity of current page swipe

return function(page, offset)
    local delta = offset - previous
    local halfpage = 0.5 * page.width
    local change = math.abs(delta) - page.width
    
    if (previous == 0) or (math.abs(change) > halfpage) then
        -- A new page swipe has begun
        velocity = delta % page.width
        if velocity > halfpage then velocity = velocity - page.width end
    end
    
    previous = offset
    return velocity
end