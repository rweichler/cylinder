return function(page, offset, flips, spread, endFlips, endSpeed, advancing, spinAtStart, tiltAngle)
    -- Defaults for optional parameters
    flips = flips or 1                      -- Number of half-turns to spin icons
    spread = spread or 1                    -- How far apart icons begin to spin
    endFlips = endFlips or flips            -- Half-turns of last icon
    endSpeed = endSpeed or 1                -- Relative speed of final icon spin
--    advancing = advancing or false          -- Swiping toward next page
--    spinAtStart = spinAtStart or false      -- Which end to spin at
    tiltAngle = tiltAngle or math.pi / 10   -- Maximum perspective angle during spin
    
    local p = (offset/page.width) % 1
    local isleft = offset < 0
    local endTime = endFlips / endSpeed
    local scale = spread + math.max(flips, endTime)
    local gap = page.width / page.max_columns
    local halfgap = 0.5 * gap
    local width = page.width - gap
    
    local t = p * scale
    
    for i, icon in subviews(page) do
        -- Icon-specific animation timeline
        local position = (icon.layer.x - halfgap) / width
        local flipCount = flips
        local flipTime = flips
        
        if advancing == spinAtStart then
            if icon.layer.x > page.width - gap then
                flipCount = endFlips
                flipTime = endTime
            end
        else
            if icon.layer.x < gap then
                flipCount = endFlips
                flipTime = endTime
            end
        end
        
        local start = (1 - position) * spread
        local stop = start + flipTime
        
        if advancing == spinAtStart then
            stop = scale - (spread - start)
            start = stop - flipTime
        end
        
        if (t < start) then
            if isleft then icon.alpha = 0 end
        elseif (t > stop) then
            if not isleft then icon.alpha = 0 end
        else
            -- Animation progress
            local frac = (t - start) / (stop - start)
            local a = -flipCount * frac
            
            -- Set visible side of spinning icon
            if isleft then
                if ((a - 0.5) % 2) > 1 then
                    icon.alpha = 0
                else
                    -- Orient the back face correctly
                    a = a + 1
                end
            else
                if ((a - 0.5) % 2) < 1 then icon.alpha = 0 end
            end
            
            -- Smoothly tilt to perspective during spin
            local tilt = 2 * tiltAngle * math.sqrt(frac * (1 - frac))
            
            icon:rotate(-tilt, 1, 0, 0)
            icon:rotate(a * math.pi, 0, 1, 0)
        end
    end
end
