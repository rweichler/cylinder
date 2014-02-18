--[[ ******************************************************************
Gather Around v1.1
by @supermamon (github.com/supermamon/cylinder-scripts/)

Trying to mimic the animation by "that other tweak".
Buggy if you keep switching in portrait and landscape mode.

v1.1 2014-02-17: Closer to the target effect.
v1.0 2014-02-17: First release.
		
******************************************************************* ]]
local saved = false

local icons ={}
local lastPageWidth=0

-- MAIN --
return function(page, offset, screen_width, screen_height)
	-- track progress
	local percent = offset/page.width
	
	-- reset positions / trying to see if this would fix folders
	if lastPageWidth ~= page.width then
		saved = false 
		icons = {}
	end
	
	-- get the center of the page
	local cx = page.width/2
	
	local cy_adj = 7 -- don't know where to get this but change it if your circle is wobbly
	local cy = page.height/2+cy_adj
	
	local radius = page.width/2*0.70 -- get 70% of the page
	
	if page.height<page.width then	
		radius = page.height/2*0.70
	end 
	
	local iconCount = #page.subviews -- seems it include empty spaces
	local theta = 360/iconCount -- this is the angle in degrees between each icon
	
	-- save the original and target icon positions
	if (saved ~= true) then

		local i = 0
		
		while true do
			i = i + 1
			local icon = page[i]
			if icon == nil then break end

			-- target
			angle = theta * i 
			angle = math.rad(angle) -- convert to radians
			
			local iconAngle = math.rad(90)-angle
			
			local px = cx+(radius * math.cos(angle))
			local py = cy-(radius * math.sin(angle))

			icons[i] = {}
				icons[i]["source"] = {}
					icons[i].source["x"] = icon.x
					icons[i].source["y"] = icon.y
		
				icons[i]["target"] = {}
					icons[i].target["x"] = px-icon.width/2
					icons[i].target["y"] = py-icon.height/2
					icons[i].target["angle"] = iconAngle
		end
		saved = true
	end
	--stayPut(page,offset)
	
    local j = 0
    while true do
        j = j + 1
        local icon = page[j]
        if icon == nil then break end
		percent = math.abs(percent) -- TIL:replicate to other pages
		
		-- if p will follow percent, the circle will only form when you reach 100%
		local p = percent*(100/40) -- complete the circle at 40% of the progress
		
		if p>=1 then p=1 end
			
		--gather
		-- move the icons towards their target positions
		local tx = (p)*(icons[j].target.x - icons[j].source.x)
		local ty = (p)*(icons[j].target.y - icons[j].source.y)
		icon:translate(tx, ty, 0)
		
		-- rotate them towards their target angles
		icon:rotate(p*icons[j].target.angle)

		if p>=1 then
			local angle = percent*math.pi*0.25 -- 45 degree rotation
			page:rotate(-angle) -- negative angle is counter-clockwise
		end


    end	
	
end
