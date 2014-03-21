local iconCube = dofile("include/iconCube.lua")

 -- This is updated every time you select this effect. You can set it manually if 
 -- you find a seed you really like, and want it to /always/ look like that.
local seed = os.time()

 -- Uncomment the line below to plant the seed in /var/mobile/Library/Logs/Cylinder/print.log
 -- Do so if you want to find which seed you like
--print (seed)

--cool seeds: 1394149256, 1394152451

local function hasMatch(list, parameter)
    for i, item in ipairs(list) do
        if (item == parameter) then return true end
        i = i + 1
    end
    
    return false
end

return function(page, offset, screen_width, screen_height)
    math.randomseed(seed)

    local isHorizontalFirst = math.random(0,1)
    if (isHorizontalFirst == 1) then
        isHorizontalFirst = true
    else
        isHorizontalFirst = false
    end

    local firstStage = {}
    local firstStageDir = {}
    local secondStage = {}
    local secondStageDir = {}
    local thirdStage = {}
    local thirdStageDir = {}
    
    -- Determine our randomizations
    if (isHorizontalFirst) then
        -- stage 1
        -- We actually create stage 3 here as well, but then move that over to the proper array
        local numRowsToSet = math.random(math.floor(page.max_rows/2), math.ceil(page.max_rows/2))
        for i=1, page.max_rows do
            local rowToSet = math.random(0, page.max_rows-1)
            
            local isDupe = true
            while (isDupe) do
                if (not hasMatch(firstStage, rowToSet)) then
                    isDupe = false
                else
                    rowToSet = math.random(0, page.max_rows-1)
                end
            end
            
            firstStage[i] = rowToSet
            firstStageDir[i] = math.random(0,1)
            if (firstStageDir[i] == 1) then
                firstStageDir[i] = true
            else
                firstStageDir[i] = false
            end
        end
        
        -- stage 2
        local numColsToSet = math.random(math.floor(page.max_columns/2), math.ceil(page.max_columns/2))
        for i=1, numColsToSet do
            local colToSet = math.random(0, page.max_columns-1)
            
            local isDupe = true
            while (isDupe) do
                if(not hasMatch(secondStage, colToSet)) then
                    isDupe = false
                else
                    colToSet = math.random(0, page.max_columns-1)
                end
            end
            
            secondStage[i] = colToSet
            secondStageDir[i] = math.random(0,1)
            if (secondStageDir[i] == 1) then
                secondStageDir[i] = true
            else
                secondStageDir[i] = false
            end
        end
        
        -- stage 3
        for i=numRowsToSet+1, page.max_rows do
            thirdStage[i-numRowsToSet] = firstStage[i]
            thirdStageDir[i-numRowsToSet] = firstStageDir[i]
            firstStage[i] = nil
            firstStageDir[i] = nil
        end
    else
        -- stage 1
        -- We actually create stage 3 here as well, but then move that over to the proper array
        local numColsToSet = math.random(math.floor(page.max_columns/2), math.ceil(page.max_columns/2))
        for i=1, page.max_columns do
            local colToSet = math.random(0, page.max_columns-1)
            
            local isDupe = true
            while (isDupe) do
                if(not hasMatch(firstStage, colToSet)) then
                    isDupe = false
                else
                    colToSet = math.random(0, page.max_columns-1)
                end
            end
            
            firstStage[i] = colToSet
            firstStageDir[i] = math.random(0,1)
            if (firstStageDir[i] == 1) then
                firstStageDir[i] = true
            else
                firstStageDir[i] = false
            end
        end
        
        -- stage 2
        local numRowsToSet = math.random(math.floor(page.max_rows/2), math.ceil(page.max_rows/2))
        for i=1, numRowsToSet do
            local rowToSet = math.random(0, page.max_rows-1)
            
            local isDupe = true
            while (isDupe) do
                if(not hasMatch(secondStage, rowToSet)) then
                    isDupe = false
                else
                    rowToSet = math.random(0, page.max_rows-1)
                end
            end
            
            secondStage[i] = rowToSet
            secondStageDir[i] = math.random(0,1)
            if (secondStageDir[i] == 1) then
                secondStageDir[i] = true
            else
                secondStageDir[i] = false
            end
        end
        
        -- stage 3
        for i=numColsToSet+1, page.max_columns do
            thirdStage[i-numColsToSet] = firstStage[i]
            thirdStageDir[i-numColsToSet] = firstStageDir[i]
            firstStage[i] = nil
            firstStageDir[i] = nil
        end
    end
    
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
