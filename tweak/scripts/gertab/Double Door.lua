--[[
    Double Door v1.0
    by gertab
 
    An effect which makes your icons look like a double door opening.
    Requested by; reddit.com/u/JerryD2T
]]
local fade = dofile("include/fade.lua")
return function(page, offset, screen_width, screen_height)
    local percent = offset/page.width
    local num = 0
    while true do
		num = num + 1
		local view = page[num]
		if view == nil then break end
		local numCopied = num%4                           -- numCopied holds the column number (1, 2, 3, 4)
		if numCopied == 0 then numCopied = 4 end          
		if numCopied == 1 or numCopied == 2 then          -- 1st and 2nd culumn
        	if percent <= 0.5 and percent >= 0 then       -- the first 50%
        		view:translate(0, 0, 0)                   
        	elseif percent >= -0.5 and percent <= 0 then  
        		view:translate(offset*2,0,0)              
        	elseif percent > 0.5 or percent < -0.5 then   
        		fade(view,percent, 2)                     
        	end                                           
        	if percent > 0.5 and percent <= 1 then        --  the last 50%
        		view.alpha = math.abs(percent)*2          
        		view:translate(percent, 0, 0)             
        	elseif percent >= -1 and percent < -0.5 then   
        		view:translate(offset*2, 0, 0)            
        		view.alpha = math.abs(percent)*2          
        	end                                           
        elseif numCopied == 3 or numCopied == 4 then      --3rd and 4th culumn
        	if percent <= 0.5 and percent >= 0 then       -- the first 50%
        		view:translate(offset*2, 0, 0)            
        	elseif percent >= -0.5 and percent <= 0 then  
        		view:translate(0,0,0)                     
        	elseif percent > 0.5 or percent < -0.5 then   
        		fade(view, math.abs(percent), 2)          
        	end                                           
        	if percent > 0.5 and percent <= 1 then        -- the last 50%
        		view:translate(offset*2, 0, 0)            
        		view.alpha = math.abs(percent)*2          
        	elseif percent >= -1 and percent < -0.5 then  
        		view:translate(percent, 0, 0)             
        		view.alpha = math.abs(percent)*2          
        	end                                                    
        end
    end
end