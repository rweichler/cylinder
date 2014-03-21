local iconCube = dofile("include/iconCube.lua")

-- Exactly the same as (complex), except this is personalized to my tastes. This exact same animation
-- can also be done by setting the seed in (complex) to 1394152451, iirc.

local function hasMatch(list, parameter)
    for i, item in ipairs(list) do
        if (item == parameter) then return true end
        i = i + 1
    end
    
    return false
end

return function(page, offset, screen_width, screen_height)

    local isHorizontalFirst = true

    local firstStage = {1, 2, 4}
    local firstStageDir = {true, false, true}
    local secondStage = {0, 2}
    local secondStageDir = {true, false}
    local thirdStage = {0, 3}
    local thirdStageDir = {true, false}
    
    local percent = offset/page.width
    
    -- A value from 0 to 1/3 that specifies how long each row should take to complete animating
    -- Change this and only this, hackers. If you make it larger than 1/3, weird things will happen.
    -- Although, that might be exactly what you want, so I'm not doing any bounds checking. Hack away
    local animationDuration = 1/3
    
    local magic = (1-animationDuration)/2 -- Adapted from another script. Literally is magic
    
    local stage1P = percent*(1/animationDuration)
    local stage2P = (percent-magic)*(1/animationDuration)
    local stage3P = (percent-2*magic)*(1/animationDuration)
    
    if (offset >= 0) then
        if (stage1P > 1) then stage1P = 1
        elseif (stage1P < 0) then stage1P = 0 end
        
        if (stage2P > 1) then stage2P = 1
        elseif (stage2P < 0) then stage2P = 0 end
        
        if (stage3P > 1) then stage3P = 1
        elseif (stage3P < 0) then stage3P = 0 end
    else
        stage1P = (percent+2*magic)*(1/animationDuration)
        stage2P = (percent+magic)*(1/animationDuration)
        stage3P = percent*(1/animationDuration)
        
        if (stage1P < -1) then stage1P = -1
        elseif (stage1P > 0) then stage1P = 0 end
        
        if (stage2P < -1) then stage2P = -1
        elseif (stage2P > 0) then stage2P = 0 end
        
        if (stage3P < -1) then stage3P = -1
        elseif (stage3P > 0) then stage3P = 0 end
    end
    
    for i, icon in subviews(page) do
        local curIconRow = math.floor((i-1)/page.max_columns)
        local curIconColumn = (i-1)%page.max_columns
        
        if (isHorizontalFirst) then
            -- Horizontal first
            
            -- stage 1
            for j, row in ipairs(firstStage) do
                if ((row == curIconRow) and (not (hasMatch(secondStage, curIconColumn) and offset < 0))) then
                    iconCube(page, i, stage1P, true, firstStageDir[j])
                end
            end
            
            -- stage 2
            for j, col in ipairs(secondStage) do
                if ((col == curIconColumn) and ((not (hasMatch(thirdStage, curIconRow) and offset < 0))
                                          and (not (hasMatch(firstStage, curIconRow) and offset >= 0)))) then
                    iconCube(page, i, stage2P, false, secondStageDir[j])
                end
            end
            
            -- stage 3
            for j, row in ipairs(thirdStage) do
                if ((row == curIconRow) and (not (hasMatch(secondStage, curIconColumn) and offset >= 0)))then
                    iconCube(page, i, stage3P, true, thirdStageDir[j])
                end
            end
        else
            -- Vertical first
            
            -- stage 1
            for j, col in ipairs(firstStage) do
                if ((col == curIconColumn) and (not (hasMatch(secondStage, curIconRow) and offset < 0))) then
                    iconCube(page, i, stage1P, false, firstStageDir[j])
                end
            end
            
            -- stage 2
            for j, row in ipairs(secondStage) do
                if ((row == curIconRow) and ((not (hasMatch(thirdStage, curIconColumn) and offset < 0))
                                          and (not (hasMatch(firstStage, curIconColumn) and offset >= 0)))) then
                    iconCube(page, i, stage2P, true, secondStageDir[j])
                end
            end
            
            -- stage 3
            for j, col in ipairs(thirdStage) do
                if ((col == curIconColumn) and (not (hasMatch(secondStage, curIconRow) and offset >= 0)))then
                    iconCube(page, i, stage3P, false, thirdStageDir[j])
                end
            end
        end
        
    end
    
    page:translate(offset, 0, 0)
end
