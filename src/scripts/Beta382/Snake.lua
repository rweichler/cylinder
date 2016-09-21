return function (page, offset, screen_width, screen_height)
    
    local percent = math.abs(offset/page.width)
    local numIcons = #page.subviews
    
    local topLeftX = nil
    local topLeftY = nil
    local iconWidth = nil
    local iconHeight = nil
    
    local xToX = nil
    local yToY = nil
    
    if (page[1]) then
        topLeftX = page[1].x
        topLeftY = page[1].y
        iconWidth = page[1].width
        iconHeight = page[1].height
        
        if (page[2]) then
            xTox = page[2].x-page[1].x
        end
        
        if (page[page.max_columns+1]) then
            yToY = page[page.max_columns+1].y-page[1].y
        end
    end
    
    for i, icon in subviews(page) do
        local iconIndex = i -- 1-indexed
        local iconRowNum = math.floor((iconIndex-1)/page.max_columns) -- 0-indexed
        if (iconRowNum%2 == 1) then
            iconIndex = iconRowNum*page.max_columns + (page.max_columns-((iconIndex-1)%page.max_columns)-1) + 1
        end
        
        local iconPercent = percent
        local iconCurRowNum = 0
        local direction = 1
        
        if (offset >= 0) then
            iconPercent = iconPercent + ((iconIndex-1)/page.max_icons)
        elseif (offset < 0) then
            iconPercent = iconPercent + ((page.max_icons-iconIndex)/page.max_icons)
        end
        
        iconCurRowNum = math.floor((iconPercent*page.max_icons)/page.max_columns)
        if (iconCurRowNum > page.max_rows-1) then iconCurRowNum = page.max_rows-1 end
        
        if (offset >= 0) then
            if (iconCurRowNum%2 == 1) then direction = -1 end
        elseif (offset < 0) then
            if ((page.max_rows-iconCurRowNum-1)%2 == 0) then direction = -1 end
        end
        
        local percentForRow = 1/page.max_rows
        
        -- determine original location
        local begX = icon.x
        local begY = icon.y
        
        -- determine destination location
        
        -- X
        -- Wanted to use modulo, but these are floats, i.e. 0.6%0.2 == 0.2 for certain values of 0.6
        local percentThroughRow = (iconPercent-(percentForRow*iconCurRowNum))*(1/(percentForRow-(percentForRow/page.max_columns)))
        
        if (percentThroughRow > 1) then percentThroughRow = 1 end
        if (percentThroughRow < 0) then percentThroughRow = 0 end
        if (iconPercent > (page.max_icons-1)/page.max_icons) then 
            percentThroughRow = 1+(iconPercent-((page.max_icons-1)/page.max_icons))*(2.5/(percentForRow-(percentForRow/page.max_columns)))
        end
        if (direction < 0) then percentThroughRow = 1-percentThroughRow end
        
        -- Removed because the icon_spacing binding wouldn't work on 64 bit devices
        -- Kept in case that gets added back
        --local maxTravelDistanceX = (page[1].width+page.icon_spacing.x)*(page.max_columns-1)
        local maxTravelDistanceX = (page.width-iconWidth-(topLeftX*2))
        if (xToX) then
            maxTravelDistanceX = xToX*(page.max_columns-1)
        end
        
        -- Y
        local percentThroughColumn = iconCurRowNum/(page.max_rows-1)
        
        -- Same deal with performing modulo with floats
        if (percentForRow-(iconPercent-(percentForRow*iconCurRowNum)) < 1/page.max_icons) then
            percentThroughColumn = percentThroughColumn + (((iconPercent-(percentForRow*iconCurRowNum))-((1/page.max_icons)*(page.max_columns-1)))*page.max_icons)/(page.max_rows-1)
        end
        if (percentThroughColumn > 1) then percentThroughColumn = 1 end
        if (percentThroughColumn < 0) then percentThroughColumn = 0 end
        if (offset < 0) then percentThroughColumn = 1-percentThroughColumn end
        
        -- Removed because the icon_spacing binding wouldn't work on 64 bit devices
        -- Kept in case that gets added back
        --local maxTravelDistanceY = (page[1].height+page.icon_spacing.y)*(page.max_rows-1)
        
        local maxTravelDistanceY = (page.height-iconHeight-(topLeftY*2))
        if (yToY) then
            maxTravelDistanceY = yToY*(page.max_rows-1)
        end
        
        local endX = (percentThroughRow*maxTravelDistanceX)+topLeftX
        local endY = (percentThroughColumn*maxTravelDistanceY)+topLeftY
        
        icon:translate(endX-begX, endY-begY, 0)
    end
    
    page:translate(offset, 0, 0)
end